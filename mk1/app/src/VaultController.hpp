#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <string>
#include <vector>

#include "PasswordEntryListModel.hpp"
#include "crusader/PasswordEntry.hpp"

namespace crusader::gui {

// Backend (QObject normal, sin Qt Widgets) que expone core/ a QML. La
// vista (qml/) solo lee propiedades y llama a metodos invocables; toda la
// logica de bloqueo/persistencia vive aqui.
class VaultController : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool isUnlocked READ isUnlocked NOTIFY isUnlockedChanged)
  Q_PROPERTY(bool vaultExists READ vaultExists NOTIFY vaultExistsChanged)
  Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
  // QObject* (no PasswordEntryListModel* directo): es lo que QML/ListView
  // esperan para usarlo como "model" sin tener que registrar
  // PasswordEntryListModel como tipo QML aparte.
  Q_PROPERTY(QObject* entries READ entriesModel CONSTANT)

 public:
  explicit VaultController(QObject* parent = nullptr);

  bool isUnlocked() const { return isUnlocked_; }
  bool vaultExists() const;
  QString errorMessage() const { return errorMessage_; }
  QObject* entriesModel() { return &entriesModel_; }

  // Crea una boveda nueva (vacia) y la deja desbloqueada. Falla si ya
  // existe una -- usar unlock() en ese caso.
  Q_INVOKABLE bool createVault(const QString& masterPassword);

  // Descifra la boveda existente con masterPassword y pobla entries.
  Q_INVOKABLE bool unlock(const QString& masterPassword);

  // Olvida la contraseña maestra y las entradas de memoria.
  Q_INVOKABLE void lock();

  // Contraseña en claro de una entrada -- separada del modelo de la lista
  // a proposito (ver PasswordEntryListModel), se pide solo al pulsar
  // "revelar" o "copiar".
  Q_INVOKABLE QString entryPassword(const QString& id) const;

  // Todos los campos de una entrada (incluida la contraseña), para
  // rellenar el formulario de edicion. Igual que entryPassword(), separado
  // del modelo de la lista a proposito -- solo se pide al entrar a
  // editar, no mientras se pinta la lista. Mapa vacio si el id no existe.
  Q_INVOKABLE QVariantMap entryDetails(const QString& id) const;

  Q_INVOKABLE bool addEntry(const QString& name, const QString& username,
                             const QString& password, const QString& url,
                             const QString& notes);
  Q_INVOKABLE bool updateEntry(const QString& id, const QString& name,
                                const QString& username, const QString& password,
                                const QString& url, const QString& notes);
  Q_INVOKABLE bool removeEntry(const QString& id);

  Q_INVOKABLE QString generatePassword(int length, bool useUpper, bool useLower,
                                        bool useDigits, bool useSymbols);

 signals:
  void isUnlockedChanged();
  void vaultExistsChanged();
  void errorMessageChanged();

 private:
  void setErrorMessage(const QString& message);
  // Reescribe el archivo con entries_ tal cual esta en memoria ahora mismo.
  bool persist();
  std::vector<crusader::PasswordEntry>::iterator findById(const QString& id);

  QString vaultPath_;
  PasswordEntryListModel entriesModel_;
  std::vector<crusader::PasswordEntry> entries_;
  // Solo vive en memoria mientras la boveda esta desbloqueada -- hace
  // falta guardarla (no solo la clave derivada) porque cada persist()
  // vuelve a llamar a saveVault(), que deriva la clave de cero con una sal
  // nueva en cada guardado (ver el comentario de VaultFile.hpp).
  std::string cachedMasterPassword_;
  bool isUnlocked_ = false;
  QString errorMessage_;
};

}  // namespace crusader::gui

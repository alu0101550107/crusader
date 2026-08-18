#pragma once

#include <QAbstractListModel>
#include <vector>

#include "crusader/PasswordEntry.hpp"

namespace crusader::gui {

// Modelo minimo para el ListView de la pantalla principal: solo expone lo
// necesario para pintar la lista (id, name, username), nunca la
// contraseña -- eso se pide aparte con VaultController::entryPassword()
// solo cuando hace falta, para no tener contraseñas en claro flotando en
// un modelo que se recorre entero para dibujar cada fila.
class PasswordEntryListModel : public QAbstractListModel {
  Q_OBJECT

 public:
  enum Role {
    IdRole = Qt::UserRole + 1,
    NameRole,
    UsernameRole,
  };

  using QAbstractListModel::QAbstractListModel;

  int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  QVariant data(const QModelIndex& index, int role) const override;
  QHash<int, QByteArray> roleNames() const override;

  // Sustituye el contenido entero del modelo. Un reset completo (en vez de
  // calcular que filas cambiaron) es mas simple y de sobra rapido para el
  // numero de entradas que maneja un gestor de contraseñas personal.
  void setEntries(const std::vector<crusader::PasswordEntry>& entries);

 private:
  std::vector<crusader::PasswordEntry> entries_;
};

}  // namespace crusader::gui

#include "VaultController.hpp"

#include <QDir>
#include <QStandardPaths>
#include <algorithm>
#include <filesystem>
#include <stdexcept>

#include "crusader/PasswordGenerator.hpp"
#include "crusader/VaultFile.hpp"

namespace crusader::gui {

VaultController::VaultController(QObject* parent) : QObject(parent) {
  // AppDataLocation resuelve a una carpeta privada de la app en las dos
  // plataformas que nos importan: ~/.local/share/<org>/<app> en escritorio
  // Linux, y el almacenamiento interno privado de la app en Android (sin
  // pedir ningun permiso de almacenamiento).
  QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
  QDir().mkpath(dir);
  vaultPath_ = dir + "/crusader.vault";

  entriesProxy_.setSourceModel(&entriesModel_);
}

bool VaultController::vaultExists() const {
  return std::filesystem::exists(vaultPath_.toStdString());
}

bool VaultController::createVault(const QString& masterPassword) {
  if (vaultExists()) {
    setErrorMessage("Ya existe una boveda -- usa unlock() para abrirla.");
    return false;
  }

  entries_.clear();
  if (!crusader::saveVault(vaultPath_.toStdString(), masterPassword.toStdString(), entries_)) {
    setErrorMessage("No se pudo crear la boveda.");
    return false;
  }

  cachedMasterPassword_ = masterPassword.toStdString();
  entriesModel_.setEntries(entries_);
  isUnlocked_ = true;
  emit isUnlockedChanged();
  emit vaultExistsChanged();
  setErrorMessage("");
  return true;
}

bool VaultController::unlock(const QString& masterPassword) {
  auto loaded = crusader::loadVault(vaultPath_.toStdString(), masterPassword.toStdString());
  if (!loaded.has_value()) {
    setErrorMessage("Contraseña incorrecta o boveda dañada.");
    return false;
  }

  entries_ = std::move(*loaded);
  cachedMasterPassword_ = masterPassword.toStdString();
  entriesModel_.setEntries(entries_);
  isUnlocked_ = true;
  emit isUnlockedChanged();
  setErrorMessage("");
  return true;
}

void VaultController::lock() {
  entries_.clear();
  cachedMasterPassword_.clear();
  entriesModel_.setEntries(entries_);
  isUnlocked_ = false;
  emit isUnlockedChanged();
}

QString VaultController::entryPassword(const QString& id) const {
  auto it = std::find_if(entries_.begin(), entries_.end(),
                          [&](const auto& e) { return e.id == id.toStdString(); });
  if (it == entries_.end()) return QString();
  return QString::fromStdString(it->password);
}

QVariantMap VaultController::entryDetails(const QString& id) const {
  auto it = std::find_if(entries_.begin(), entries_.end(),
                          [&](const auto& e) { return e.id == id.toStdString(); });
  if (it == entries_.end()) return QVariantMap();

  QVariantMap details;
  details["name"] = QString::fromStdString(it->name);
  details["username"] = QString::fromStdString(it->username);
  details["password"] = QString::fromStdString(it->password);
  details["url"] = QString::fromStdString(it->url);
  details["notes"] = QString::fromStdString(it->notes);
  return details;
}

bool VaultController::addEntry(const QString& name, const QString& username,
                                const QString& password, const QString& url,
                                const QString& notes) {
  entries_.push_back(crusader::makeEntry(name.toStdString(), username.toStdString(),
                                          password.toStdString(), url.toStdString(),
                                          notes.toStdString()));
  if (!persist()) {
    entries_.pop_back();
    return false;
  }
  entriesModel_.setEntries(entries_);
  return true;
}

bool VaultController::updateEntry(const QString& id, const QString& name,
                                   const QString& username, const QString& password,
                                   const QString& url, const QString& notes) {
  auto it = findById(id);
  if (it == entries_.end()) {
    setErrorMessage("Entrada no encontrada.");
    return false;
  }

  crusader::PasswordEntry backup = *it;
  it->name = name.toStdString();
  it->username = username.toStdString();
  it->password = password.toStdString();
  it->url = url.toStdString();
  it->notes = notes.toStdString();
  crusader::touch(*it);

  if (!persist()) {
    *it = backup;
    return false;
  }
  entriesModel_.setEntries(entries_);
  return true;
}

bool VaultController::removeEntry(const QString& id) {
  auto it = findById(id);
  if (it == entries_.end()) return false;

  crusader::PasswordEntry backup = *it;
  entries_.erase(it);
  if (!persist()) {
    entries_.push_back(backup);
    return false;
  }
  entriesModel_.setEntries(entries_);
  return true;
}

QString VaultController::generatePassword(int length, bool useUpper, bool useLower,
                                           bool useDigits, bool useSymbols) {
  crusader::PasswordGeneratorOptions options;
  options.length = static_cast<std::size_t>(length);
  options.useUpper = useUpper;
  options.useLower = useLower;
  options.useDigits = useDigits;
  options.useSymbols = useSymbols;

  try {
    return QString::fromStdString(crusader::generatePassword(options));
  } catch (const std::invalid_argument& e) {
    setErrorMessage(QString::fromStdString(e.what()));
    return QString();
  }
}

void VaultController::setErrorMessage(const QString& message) {
  if (errorMessage_ == message) return;
  errorMessage_ = message;
  emit errorMessageChanged();
}

bool VaultController::persist() {
  if (!crusader::saveVault(vaultPath_.toStdString(), cachedMasterPassword_, entries_)) {
    setErrorMessage("No se pudo guardar la boveda.");
    return false;
  }
  return true;
}

std::vector<crusader::PasswordEntry>::iterator VaultController::findById(const QString& id) {
  return std::find_if(entries_.begin(), entries_.end(),
                       [&](const auto& e) { return e.id == id.toStdString(); });
}

}  // namespace crusader::gui

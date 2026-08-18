#include "PasswordEntryListModel.hpp"

namespace crusader::gui {

int PasswordEntryListModel::rowCount(const QModelIndex& parent) const {
  if (parent.isValid()) return 0;
  return static_cast<int>(entries_.size());
}

QVariant PasswordEntryListModel::data(const QModelIndex& index, int role) const {
  if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(entries_.size())) {
    return QVariant();
  }
  const crusader::PasswordEntry& entry = entries_[static_cast<std::size_t>(index.row())];
  switch (role) {
    case IdRole:
      return QString::fromStdString(entry.id);
    case NameRole:
      return QString::fromStdString(entry.name);
    case UsernameRole:
      return QString::fromStdString(entry.username);
    default:
      return QVariant();
  }
}

QHash<int, QByteArray> PasswordEntryListModel::roleNames() const {
  return {
      {IdRole, "entryId"},
      {NameRole, "name"},
      {UsernameRole, "username"},
  };
}

void PasswordEntryListModel::setEntries(const std::vector<crusader::PasswordEntry>& entries) {
  beginResetModel();
  entries_ = entries;
  endResetModel();
}

}  // namespace crusader::gui

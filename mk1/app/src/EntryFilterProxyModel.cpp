#include "EntryFilterProxyModel.hpp"

#include "PasswordEntryListModel.hpp"

namespace crusader::gui {

EntryFilterProxyModel::EntryFilterProxyModel(QObject* parent) : QSortFilterProxyModel(parent) {}

void EntryFilterProxyModel::setFilterText(const QString& text) {
  if (filterText_ == text) return;
  beginFilterChange();
  filterText_ = text;
  endFilterChange(QSortFilterProxyModel::Direction::Rows);
  emit filterTextChanged();
}

bool EntryFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const {
  if (filterText_.isEmpty()) return true;

  QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  QString name = sourceModel()->data(index, PasswordEntryListModel::NameRole).toString();
  QString username = sourceModel()->data(index, PasswordEntryListModel::UsernameRole).toString();

  return name.contains(filterText_, Qt::CaseInsensitive) ||
         username.contains(filterText_, Qt::CaseInsensitive);
}

}  // namespace crusader::gui

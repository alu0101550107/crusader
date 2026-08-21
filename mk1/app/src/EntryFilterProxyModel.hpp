#pragma once

#include <QSortFilterProxyModel>
#include <QString>

namespace crusader::gui {

// Filtra PasswordEntryListModel por nombre O usuario (no columnas
// distintas: los dos son roles del mismo modelo de una sola columna), asi
// que hace falta un filterAcceptsRow() propio -- el filtro de una sola
// columna que trae QSortFilterProxyModel de fabrica (filterRole +
// setFilterFixedString) solo compara un rol a la vez.
class EntryFilterProxyModel : public QSortFilterProxyModel {
  Q_OBJECT
  Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)

 public:
  explicit EntryFilterProxyModel(QObject* parent = nullptr);

  QString filterText() const { return filterText_; }
  void setFilterText(const QString& text);

 signals:
  void filterTextChanged();

 protected:
  bool filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const override;

 private:
  QString filterText_;
};

}  // namespace crusader::gui

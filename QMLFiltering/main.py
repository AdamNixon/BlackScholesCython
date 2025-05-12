import sys
from PySide6.QtCore import QAbstractTableModel, Qt, QSortFilterProxyModel, QItemSelectionModel, QModelIndex
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Slot, Property

# Sample data
data = [
    {"name": "Apple", "type": "Fruit", "description": "A sweet red or green fruit"},
    {"name": "Carrot", "type": "Vegetable", "description": "An orange crunchy vegetable"},
    {"name": "Banana", "type": "Fruit", "description": "A long yellow fruit"},
    {"name": "Broccoli", "type": "Vegetable", "description": "A green leafy vegetable"},
    {"name": "Orange", "type": "Fruit", "description": "A juicy citrus fruit"},
]

# Table model for the data
class TableModel(QAbstractTableModel):
    def __init__(self, data):
        super().__init__()
        self._data = data
        self._headers = ["Name", "Type", "Description"]
        self._selected_rows = set()

    def rowCount(self, parent=None):
        return len(self._data)

    def columnCount(self, parent=None):
        return len(self._headers)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None
        if role == Qt.DisplayRole:
            row = index.row()
            col = index.column()
            if col == 0:
                return self._data[row]["name"]
            elif col == 1:
                return self._data[row]["type"]
            elif col == 2:
                return self._data[row]["description"]
        return None

    def headerData(self, section, orientation, role=Qt.DisplayRole):
        if role == Qt.DisplayRole and orientation == Qt.Horizontal:
            return self._headers[section]
        return None

    @Slot(int, bool)
    def setSelected(self, row, selected):
        print(f"setSelected called: row={row}, selected={selected}")  # Debug
        if selected:
            self._selected_rows.add(row)
        else:
            self._selected_rows.discard(row)
        print(f"Selected rows: {self._selected_rows}")  # Debug
        self.selectedItemsChanged.emit()

    @Slot(int, result=bool)
    def isSelected(self, row):
        return row in self._selected_rows

    @Slot()
    def clearSelection(self):
        self._selected_rows.clear()
        self.selectedItemsChanged.emit()

    @Signal
    def selectedItemsChanged(self):
        pass

    @Property(list, notify=selectedItemsChanged)
    def selectedItems(self):
        return [self._data[row] for row in sorted(self._selected_rows)]

# Proxy model for filtering
class FilterProxyModel(QSortFilterProxyModel):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._filter_text = ""

    @Slot(str)
    def setFilterText(self, text):
        self._filter_text = text.lower()
        self.invalidateFilter()

    def filterAcceptsRow(self, source_row, source_parent):
        if not self._filter_text:
            return True
        source_model = self.sourceModel()
        for col in range(source_model.columnCount()):
            index = source_model.index(source_row, col, source_parent)
            data = source_model.data(index, Qt.DisplayRole)
            if data and self._filter_text in data.lower():
                return True
        return False

def main():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Create models
    table_model = TableModel(data)
    proxy_model = FilterProxyModel()
    proxy_model.setSourceModel(table_model)

    # Expose models to QML
    engine.rootContext().setContextProperty("tableModel", proxy_model)
    engine.rootContext().setContextProperty("sourceModel", table_model)

    # Load QML file
    engine.load("main.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
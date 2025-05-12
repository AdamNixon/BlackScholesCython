import sys
import os

from PySide6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QLineEdit, QTableView, QLabel,
    QListWidget, QHeaderView
)
from PySide6.QtCore import Qt, QSortFilterProxyModel, QRegularExpression
from PySide6.QtGui import QStandardItemModel, QStandardItem, QFont

class FilterProxyModel(QSortFilterProxyModel):
    def __init__(self):
        super().__init__()
        self.setFilterCaseSensitivity(Qt.CaseInsensitive)
        self.setFilterKeyColumn(-1)

    def filterAcceptsRow(self, source_row, source_parent):
        model = self.sourceModel()
        regex = self.filterRegularExpression()
        for column in range(model.columnCount()):
            index = model.index(source_row, column, source_parent)
            data = model.data(index)
            if data and regex.match(data).hasMatch():
                return True
        return False


class ItemTableApp(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Styled Item Picker")
        self.resize(700, 500)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(12, 12, 12, 12)
        layout.setSpacing(10)

        self.search_bar = QLineEdit()
        self.search_bar.setPlaceholderText("Search...")
        layout.addWidget(self.search_bar)

        self.table_view = QTableView()
        self.table_view.setAlternatingRowColors(True)
        self.table_view.setSelectionBehavior(QTableView.SelectRows)
        self.table_view.setSelectionMode(QTableView.MultiSelection)
        layout.addWidget(self.table_view)

        self.selected_label = QLabel("Selected Items:")
        layout.addWidget(self.selected_label)

        self.selected_list = QListWidget()
        layout.addWidget(self.selected_list)

        # Data Model
        self.model = QStandardItemModel(0, 3)
        self.model.setHorizontalHeaderLabels(["Name", "Type", "Description"])

        data = [
            ("Hammer", "Tool", "Used for hitting nails."),
            ("Screwdriver", "Tool", "Used to drive screws."),
            ("Apple", "Fruit", "A sweet red fruit."),
            ("Banana", "Fruit", "A long yellow fruit."),
            ("Wrench", "Tool", "Used to grip and turn objects."),
            ("Drill", "Tool", "Used to make holes."),
            ("Pear", "Fruit", "Juicy green fruit."),
        ]

        for name, type_, desc in data:
            self.model.appendRow([
                QStandardItem(name),
                QStandardItem(type_),
                QStandardItem(desc)
            ])

        self.proxy_model = FilterProxyModel()
        self.proxy_model.setSourceModel(self.model)
        self.table_view.setModel(self.proxy_model)

        header = self.table_view.horizontalHeader()
        header.setStretchLastSection(True)
        header.setSectionResizeMode(QHeaderView.Stretch)

        self.search_bar.textChanged.connect(self.on_search_text_changed)
        self.table_view.selectionModel().selectionChanged.connect(self.update_selected_list)

        self.apply_styles()

    def on_search_text_changed(self, text):
        regex = QRegularExpression(text, QRegularExpression.CaseInsensitiveOption)
        self.proxy_model.setFilterRegularExpression(regex)

    def update_selected_list(self):
        self.selected_list.clear()
        selected_indexes = self.table_view.selectionModel().selectedRows()
        for index in selected_indexes:
            source_index = self.proxy_model.mapToSource(index)
            name = self.model.item(source_index.row(), 0).text()
            self.selected_list.addItem(name)

    def apply_styles(self):
        self.setStyleSheet("""
            QWidget {
                font-family: "Segoe UI", sans-serif;
                font-size: 11pt;
                background-color: #f9f9f9;
            }

            QLineEdit {
                padding: 6px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }

            QTableView {
                border: 1px solid #ccc;
                background-color: #ffffff;
                alternate-background-color: #f0f0f0;
                selection-background-color: #87cefa;
                selection-color: black;
                gridline-color: #ddd;
            }

            QHeaderView::section {
                background-color: #f1f1f1;
                padding: 4px;
                border: 1px solid #ddd;
            }

            QListWidget {
                border: 1px solid #ccc;
                background-color: #fff;
                padding: 4px;
            }

            QLabel {
                font-weight: bold;
                color: #333;
            }
        """)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyle("Fusion")  # Optional: use built-in polished style
    window = ItemTableApp()
    window.show()
    sys.exit(app.exec())

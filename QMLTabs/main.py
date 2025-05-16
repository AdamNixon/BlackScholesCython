import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QAbstractListModel, Qt

# TabModel for tab data
class TabModel(QAbstractListModel):
    TitleRole = Qt.UserRole + 1
    ContentRole = Qt.UserRole + 2

    def __init__(self, parent=None):
        super().__init__(parent)
        self._tabs = [
            {"title": "Tab 1", "content": "This is the content for Tab 1."},
            {"title": "Tab 2", "content": "This is the content for Tab 2."},
            {"title": "Tab 3", "content": "This is the content for Tab 3."}
        ]

    def rowCount(self, parent):
        return len(self._tabs)

    def data(self, index, role):
        if not index.isValid() or index.row() >= len(self._tabs):
            return None
        tab = self._tabs[index.row()]
        if role == self.TitleRole:
            return tab["title"]
        elif role == self.ContentRole:
            return tab["content"]
        return None

    def roleNames(self):
        return {
            self.TitleRole: b"title",
            self.ContentRole: b"content"
        }

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    
    # Create and register the model
    tab_model = TabModel()
    
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("tabModel", tab_model)
    
    # Load the main QML file
    qml_file = os.path.join(os.path.dirname(__file__), "qml/main.qml")
    print(f"Loading QML file: {qml_file}")
    engine.load(qml_file)
    
    if not engine.rootObjects():
        print("Failed to load QML root objects")
        sys.exit(-1)
    
    print("Application started")
    sys.exit(app.exec())
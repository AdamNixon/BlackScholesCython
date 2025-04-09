import sys
import numpy as np
from PySide6.QtWidgets import (QApplication, QMainWindow, QListWidget, QPushButton, 
                              QVBoxLayout, QWidget, QDialog, QTableWidget, QTableWidgetItem, QHBoxLayout)
from PySide6.QtCore import QTimer, Signal, Slot, QObject, QDate
from stock_simulator_wrapper import PyStockSimulator

class StockForecastSignals(QObject):
    update_prices = Signal()

class ForecastDialog(QDialog):
    def __init__(self, stock_names, initial_prices, means, speeds, volatilities, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Stock Price Forecast")
        self.stock_names = stock_names
        self.initial_prices = initial_prices
        self.means = means
        self.speeds = speeds
        self.volatilities = volatilities
        self.num_stocks = len(stock_names)

        self.signals = StockForecastSignals()

        self.table = QTableWidget()
        self.table.setRowCount(31)
        self.table.setColumnCount(self.num_stocks + 1)
        self.table.setHorizontalHeaderLabels(["Date"] + self.stock_names)
        self.table.setEditTriggers(QTableWidget.NoEditTriggers)

        layout = QVBoxLayout()
        layout.addWidget(self.table)
        self.setLayout(layout)

        self.signals.update_prices.connect(self.update_table)
        self.update_table()

        self.timer = QTimer(self)
        self.timer.timeout.connect(self.signals.update_prices.emit)
        self.timer.start(5000)

    @Slot()
    def update_table(self):
        start_date = QDate(2025, 4, 9)
        dates = [start_date.addDays(i).toString("yyyy-MM-dd") for i in range(31)]

        simulator = PyStockSimulator(self.initial_prices.tolist(), self.means.tolist(),
                                    self.speeds.tolist(), self.volatilities.tolist())
        
        prices = [self.initial_prices.copy()]
        for _ in range(30):
            next_prices = simulator.get_next_prices()
            prices.append(np.array(next_prices))
        prices = np.array(prices)

        for row in range(31):
            self.table.setItem(row, 0, QTableWidgetItem(dates[row]))
            for col in range(self.num_stocks):
                price_str = f"{prices[row, col]:.2f}"
                self.table.setItem(row, col + 1, QTableWidgetItem(price_str))

        self.table.resizeColumnsToContents()

class MainWindow(QMainWindow):
    show_forecast_signal = Signal(list, np.ndarray, np.ndarray, np.ndarray, np.ndarray)

    def __init__(self):
        super().__init__()
        self.setWindowTitle("Stock Selector")
        
        # Predefined stocks
        self.stocks = {
            "AAPL": {"initial_price": 150.0, "mean": 150.0, "speed": 0.1, "volatility": 0.01},
            "GOOG": {"initial_price": 2800.0, "mean": 2800.0, "speed": 0.05, "volatility": 0.02},
            "MSFT": {"initial_price": 300.0, "mean": 300.0, "speed": 0.08, "volatility": 0.015},
        }

        # UI components
        self.available_list = QListWidget()
        self.available_list.addItems(self.stocks.keys())
        self.available_list.itemDoubleClicked.connect(self.move_to_selected)

        self.selected_list = QListWidget()
        self.selected_list.itemDoubleClicked.connect(self.move_to_available)

        self.button = QPushButton("Show Forecast")
        self.button.clicked.connect(self.prepare_forecast)

        # Layout
        list_layout = QHBoxLayout()
        list_layout.addWidget(self.available_list)
        list_layout.addWidget(self.selected_list)

        main_layout = QVBoxLayout()
        main_layout.addLayout(list_layout)
        main_layout.addWidget(self.button)

        container = QWidget()
        container.setLayout(main_layout)
        self.setCentralWidget(container)

        # Connect signal to slot
        self.show_forecast_signal.connect(self.show_forecast_dialog)

    @Slot(QListWidget)
    def move_to_selected(self, item):
        # Move item from available to selected
        self.available_list.takeItem(self.available_list.row(item))
        self.selected_list.addItem(item.text())

    @Slot(QListWidget)
    def move_to_available(self, item):
        # Move item from selected to available
        self.selected_list.takeItem(self.selected_list.row(item))
        self.available_list.addItem(item.text())

    @Slot()
    def prepare_forecast(self):
        selected_items = [self.selected_list.item(i).text() for i in range(self.selected_list.count())]
        if not selected_items:
            return
        stock_names = selected_items
        initial_prices = np.array([self.stocks[s]["initial_price"] for s in stock_names], dtype=np.float64)
        means = np.array([self.stocks[s]["mean"] for s in stock_names], dtype=np.float64)
        speeds = np.array([self.stocks[s]["speed"] for s in stock_names], dtype=np.float64)
        volatilities = np.array([self.stocks[s]["volatility"] for s in stock_names], dtype=np.float64)

        self.show_forecast_signal.emit(stock_names, initial_prices, means, speeds, volatilities)

    @Slot(list, np.ndarray, np.ndarray, np.ndarray, np.ndarray)
    def show_forecast_dialog(self, stock_names, initial_prices, means, speeds, volatilities):
        dialog = ForecastDialog(stock_names, initial_prices, means, speeds, volatilities, self)
        dialog.exec()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
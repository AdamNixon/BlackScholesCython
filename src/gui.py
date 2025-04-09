import sys
from PySide6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                               QHBoxLayout, QLabel, QLineEdit, QPushButton)
from PySide6.QtCore import Qt
import monte_carlo_wrapper as monte_carlo  # Import the Cython-compiled module

class OptionPricerWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Monte Carlo Option Pricer")
        self.setGeometry(100, 100, 400, 300)

        # Main widget and layout
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        layout = QVBoxLayout(main_widget)

        # Input fields with labels
        self.inputs = {}
        params = [
            ("Initial Stock Price (S0)", "100.0"),
            ("Strike Price (K)", "105.0"),
            ("Risk-Free Rate (r)", "0.05"),
            ("Volatility (sigma)", "0.2"),
            ("Time to Expiration (T)", "1.0"),
            ("Number of Simulations", "1000000"),
        ]

        for label_text, default_value in params:
            h_layout = QHBoxLayout()
            label = QLabel(label_text)
            input_field = QLineEdit(default_value)
            input_field.setAlignment(Qt.AlignRight)
            h_layout.addWidget(label)
            h_layout.addWidget(input_field)
            layout.addLayout(h_layout)
            self.inputs[label_text] = input_field

        # Calculate button
        self.calculate_button = QPushButton("Calculate Price")
        self.calculate_button.clicked.connect(self.calculate_price)
        layout.addWidget(self.calculate_button)

        # Result label
        self.result_label = QLabel("Option Price: N/A")
        self.result_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(self.result_label)

        # Spacer to push content up
        layout.addStretch()

    def calculate_price(self):
        try:
            # Extract input values
            S0 = float(self.inputs["Initial Stock Price (S0)"].text())
            K = float(self.inputs["Strike Price (K)"].text())
            r = float(self.inputs["Risk-Free Rate (r)"].text())
            sigma = float(self.inputs["Volatility (sigma)"].text())
            T = float(self.inputs["Time to Expiration (T)"].text())
            total_simulations = int(self.inputs["Number of Simulations"].text())

            # Call the Monte Carlo function
            price = monte_carlo.price_call_option(S0, K, r, sigma, T, total_simulations)
            self.result_label.setText(f"Option Price: {price:.5f}")
        except ValueError as e:
            self.result_label.setText("Error: Invalid input (use numbers)")
        except Exception as e:
            self.result_label.setText(f"Error: {str(e)}")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = OptionPricerWindow()
    window.show()
    sys.exit(app.exec())
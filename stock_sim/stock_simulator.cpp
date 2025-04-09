#include "stock_simulator.h"
#include <cmath>

StockSimulator::StockSimulator(const std::vector<double>& initial_prices,
                               const std::vector<double>& means,
                               const std::vector<double>& speeds,
                               const std::vector<double>& volatilities)
    : current_prices(initial_prices),
      means(means),
      speeds(speeds),
      volatilities(volatilities),
      gen(std::random_device{}()),
      dist(0.0, 1.0) {}

void StockSimulator::get_next_prices(std::vector<double>& next_prices) {
    next_prices.resize(current_prices.size());
    for (size_t i = 0; i < current_prices.size(); ++i) {
        double z = dist(gen);
        next_prices[i] = current_prices[i] +
                         speeds[i] * (means[i] - current_prices[i]) +
                         volatilities[i] * std::sqrt(1.0) * z;
        current_prices[i] = next_prices[i];
    }
}
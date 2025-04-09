#ifndef STOCK_SIMULATOR_H
#define STOCK_SIMULATOR_H

#include <vector>
#include <random>

class StockSimulator {
public:
    StockSimulator(const std::vector<double>& initial_prices,
                   const std::vector<double>& means,
                   const std::vector<double>& speeds,
                   const std::vector<double>& volatilities);
    void get_next_prices(std::vector<double>& next_prices);

private:
    std::vector<double> current_prices;
    std::vector<double> means;
    std::vector<double> speeds;
    std::vector<double> volatilities;
    std::mt19937 gen;
    std::normal_distribution<double> dist;
};

#endif
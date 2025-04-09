#ifndef MONTE_CARLO_HPP
#define MONTE_CARLO_HPP
#include <cstddef>
// Header file for the C++ pricing
double monte_carlo_call_option(double S0, double K, double r, double sigma, double T, std::size_t total_simulations);

#endif
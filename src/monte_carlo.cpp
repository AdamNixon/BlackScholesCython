#include "monte_carlo.hpp"
#include <vector>
#include <thread>
#include <random>
#include <cmath>
#include <numeric>

// Simulate one path and compute discounted payoff
double simulate_payoff(double S0, double K, double r, double sigma, double T, std::mt19937& rng) {
    std::normal_distribution<double> norm(0.0, 1.0);
    double z = norm(rng);
    double drift = (r - 0.5 * sigma * sigma) * T;
    double diffusion = sigma * std::sqrt(T) * z;
    double ST = S0 * std::exp(drift + diffusion);
    double payoff = std::max(ST - K, 0.0);
    return std::exp(-r * T) * payoff;
}

// Thread function for partial sum
void monte_carlo_thread(double S0, double K, double r, double sigma, double T, 
                       size_t num_simulations, unsigned int seed, double& result) {
    std::mt19937 rng(seed);
    result = 0.0;
    for (size_t i = 0; i < num_simulations; ++i) {
        result += simulate_payoff(S0, K, r, sigma, T, rng);
    }
}

// Main exported function
double monte_carlo_call_option(double S0, double K, double r, double sigma, double T, size_t total_simulations) {
    const size_t num_threads = std::thread::hardware_concurrency();
    std::vector<std::thread> threads;
    std::vector<double> partial_results(num_threads, 0.0);

    size_t sims_per_thread = total_simulations / num_threads;
    std::random_device rd;
    for (size_t i = 0; i < num_threads; ++i) {
        size_t sims = (i == num_threads - 1) ? (total_simulations - i * sims_per_thread) : sims_per_thread;
        unsigned int seed = rd();
        threads.emplace_back(monte_carlo_thread, S0, K, r, sigma, T, sims, seed, std::ref(partial_results[i]));
    }

    for (auto& t : threads) {
        t.join();
    }

    double total_payoff = std::accumulate(partial_results.begin(), partial_results.end(), 0.0);
    return total_payoff / total_simulations;
}
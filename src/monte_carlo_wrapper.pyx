# cython: language_level=3

# Declare the C++ function
cdef extern from "monte_carlo.hpp":
    double monte_carlo_call_option(double S0, double K, double r, double sigma, double T, size_t total_simulations)

# Python wrapper function
def price_call_option(double S0, double K, double r, double sigma, double T, size_t total_simulations=1000000):
    """
    Price a European call option using Monte Carlo simulation with Black-Scholes model.
    
    Args:
        S0 (float): Initial stock price
        K (float): Strike price
        r (float): Risk-free rate
        sigma (float): Volatility
        T (float): Time to expiration (in years)
        total_simulations (int): Number of Monte Carlo simulations (default: 1,000,000)
    
    Returns:
        float: Estimated option price
    """
    return monte_carlo_call_option(S0, K, r, sigma, T, total_simulations)
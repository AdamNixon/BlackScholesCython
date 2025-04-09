import monte_carlo_wrapper as monte_carlo

# Option parameters
S0 = 100.0  # Initial stock price
K = 105.0   # Strike price
r = 0.05    # Risk-free rate (5%)
sigma = 0.2 # Volatility (20%)
T = 1.0     # Time to expiration (1 year)

# Price the option
price = monte_carlo.price_call_option(S0, K, r, sigma, T)
print(f"Monte Carlo Call Option Price: {price:.5f}")
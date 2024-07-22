import numpy as np
from scipy.stats import norm
import json

def gaussian_cdf(x, mu=0, sigma=1):
    a1 = 0.0705230784
    a2 = 0.0422820123
    a3 = 0.0092705272
    a4 = 0.0001520143
    a5 = 0.0002765672
    a6 = 0.0000430638
    
    z = ((x - mu) / sigma) / np.sqrt(2)

    if (z < -4):
        return 0
    elif (z > 4):
        return 1

    abs_z = np.abs(z)
    
    erf_approx = 1 - (1 / (1 + a1 * abs_z + a2 * abs_z**2 + a3 * abs_z**3 + a4 * abs_z**4 + a5 * abs_z**5 + a6 * abs_z**6)**16)
    
    cdf = 0.5 * (1 + np.sign(z) * erf_approx)
    
    return cdf

def generate_test_data(num_cases=10000):
    test_cases = []

    np.random.seed(420)

    x_range = (-1e5, 1e5)
    mu_range = (-1e2, 1e2)
    sigma_range = (1e-18, 1)

    for _ in range(num_cases):
        x = np.random.uniform(*x_range)
        mu = np.random.uniform(*mu_range)
        sigma = np.random.uniform(*sigma_range)

        expected = norm.cdf(x, mu, sigma)
        estimated = gaussian_cdf(x, mu, sigma)
        if expected != 0 and expected != 1:
            print("-----------------------------")
            print("Expected: ", expected)
            print("Estimated: ", estimated)
            print("Error is within the tolerance range: ", abs(expected - estimated) < 1e-8)

        test_cases.append({
            'estimated_cdf': int(estimated * 1e18),
            'expected_cdf': int(expected * 1e18),
            'mu': int(mu * 1e18),
            'sigma': int(sigma * 1e18),
            'x': int(x * 1e18),
        })

    with open('data/test_data.json', 'w') as f:
        json.dump(test_cases, f, indent=4)

if __name__ == "__main__":
    generate_test_data()

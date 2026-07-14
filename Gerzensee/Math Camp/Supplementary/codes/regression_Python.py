# --------------------------------------------------------
# Regression
# --------------------------------------------------------

import numpy as np
import matplotlib.pyplot as plt

# Printing the outputs as a text file if == 1
output_file = 0

# Sample size
n = 500

# True parameter values
beta_1 = 1
beta_2 = 3
beta_vec = np.array([[beta_1], [beta_2]]) # (2,1)-vector

# --------------------------------------------------------
# Generating Observations
# --------------------------------------------------------
np.random.seed(1)  # Random number generator seed

# (n,1)-vectors of iid standard normal variables
x = np.random.randn(n, 1)
e = np.random.randn(n, 1)

X = np.hstack([np.ones((n, 1)), x])  # (n,2)-matrix
y = X @ beta_vec + e                 # (n,1)-vector

# --------------------------------------------------------
# Estimating Best Beta
# --------------------------------------------------------
# Manual Projection: inv(X'*X)*X'*y
beta_hat = np.linalg.inv(X.T @ X) @ X.T @ y

# Python 'np.linalg.lstsq' function
beta_hat_2, _, _, _ = np.linalg.lstsq(X, y, rcond=None)

# --------------------------------------------------------
# Creating the Regression Line for Figure
# --------------------------------------------------------
x_min = -4
x_max = 4
x_ax = np.linspace(x_min, x_max, 100)

# --------------------------------------------------------
# Output
# --------------------------------------------------------
line1 = f"Projection: beta=({beta_hat[0][0]:.6f},{beta_hat[1][0]:.6f})"
line2 = f"Python np.linalg.lstsq: beta=({beta_hat[0][0]:.6f},{beta_hat[1][0]:.6f})"

print(line1)
print(line2)

if output_file == 1:
    # 'w' automatically clears/overwrites the file if it exists
    with open('regression_py.txt', 'w') as f:
        print(line1, file=f)
        print(line2, file=f)

# --------------------------------------------------------
# Figure Generation
# -------------------------------------------------------- 
plt.figure()
plt.plot(x, y, '.')
plt.plot(x_ax, beta_hat[0][0] + beta_hat[1][0] * x_ax)
plt.xlim([x_min, x_max])
plt.ylim([beta_1 + beta_2 * x_min, beta_1 + beta_2 * x_max])
reg_eq = rf'$y = {beta_hat[0][0]:.3f} + {beta_hat[1][0]:.3f}x$'
plt.text(-3.75, 2, reg_eq, fontsize=12)
plt.xlabel(r'$x$', fontsize=12)
plt.ylabel(r'$y$', fontsize=12)
plt.title('Regression: Example', fontsize=14)
plt.show()
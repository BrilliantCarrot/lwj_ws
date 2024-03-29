import numpy as np
from scipy.linalg import lu

# Define the matrix A
A = np.array([
    [1, 2, -2, 2],
    [0, 2, 1, 1],
    [1, -1, 1, 1],
    [1, 1, 0, -3],
    [-7, -2, 0, 0]
])

# Perform LU decomposition
P, L, U = lu(A)

# Print the matrices P, L, and U
print("P = ")
print(P)
print("\\nL = ")
print(L)
print("\\nU = ")
print(U)
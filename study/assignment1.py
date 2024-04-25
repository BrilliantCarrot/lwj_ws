import numpy as np
from scipy.linalg import lu
from scipy.linalg import svd
from sympy import Matrix

## 문제1
# Define the matrix A
# A = np.array([
#     [1, 2, -2, 2],
#     [0, 2, 1, 1],
#     [1, -1, 1, 1],
#     [1, 1, 0, -3],
#     [-7, -2, 0, 0]
# ])

# # Perform LU decomposition
# P, L, U = lu(A)

# # Print the matrices P, L, and U
# print("P = ")
# print(P)
# print("\\nL = ")
# print(L)
# print("\\nU = ")
# print(U)

## 문제2
import numpy as np
from scipy.linalg import lu, null_space

# Define the matrix A
A = np.array([[1, 2, 0, 2, 1],
              [-1, -2, 1, 1, 0],
              [1, 2, -3, -7, -2]])

# Compute the LU decomposition of A
P, L, U = lu(A)

# Compute the four fundamental subspaces
# 1. Column space, C(A)
_, _, Vh = np.linalg.svd(A)
r = np.linalg.matrix_rank(A)
C_A = Vh.T[:, :r]

# 2. Null space, N(A)
N_A = null_space(U)

# 3. Row space, C(A.T)
_, _, Vh = np.linalg.svd(A.T)
r = np.linalg.matrix_rank(A.T)
C_A_T = Vh.T[:, :r]

# 4. Left null space, N(A.T)
N_A_T = null_space(A.T)

# Print the results
print("Matrix A:")
print(A)
print("\\nMatrix U:")
print(U)
print("\\nColumn space of A:")
print(C_A)
print("\\nNull space of A:")
print(N_A)
print("\\nRow space of A:")
print(C_A_T)
print("\\nLeft null space of A:")
print(N_A_T)

#Add a code section to get the dimension of the four fundamental subspaces
print("Dimension of the column space of A: ", C_A.shape[1])
print("Dimension of the null space of A: ", N_A.shape[1])
print("Dimension of the row space of A: ", C_A_T.shape[1])
print("Dimension of the left null space of A: ", N_A_T.shape[1])
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
A = np.array([
    [1, 2, 0, 2, 1],
    [-1, -2, 1, 1, 0],
    [1, 2, -3, -7, -2]
])

# # Perform Singular Value Decomposition (SVD)
# U, s, VT = svd(A)

# Perform LU decomposition
P, L, U = lu(A)

# # The rank of the matrix is the number of non-zero singular values
# rank = np.sum(s > 1e-10)

# # Column space of A is spanned by the first 'rank' columns of U
# column_space = U[:, :rank]

# # Null space of A is spanned by the last 'n-rank' columns of VT.T
# null_space = VT.T[:, rank:]

# # Row space of A is spanned by the first 'rank' rows of VT
# row_space = VT[:rank, :]

# # Left null space of A is spanned by the last 'm-rank' columns of U
# left_null_space = U[:, rank:]

# Print the four fundamental subspaces
print("U:")
print(U)
# print("rank of A matrix:")
# print(rank)
# print("Column space of A:")
# print(column_space)
# print("\\nNull space of A:")
# print(null_space)
# print("\\nRow space of A:")
# print(row_space)
# print("\\nLeft null space of A:")
# print(left_null_space)
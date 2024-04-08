import numpy as np
from osgeo import gdal
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Enable GDAL exceptions
gdal.UseExceptions()

# Load DEM data
dem_file = 'C:/Users/leeyj/Downloads/Test_DEM.tif'
dataset = gdal.Open(dem_file)
band = dataset.GetRasterBand(1)
elevation = band.ReadAsArray()

# Get geotransform info
geotransform = dataset.GetGeoTransform()

# Initialize an empty list to store the data
matrix = []

# Calculate longitude, latitude, and elevation for each pixel
for y in range(elevation.shape[0]):
    row = []
    for x in range(elevation.shape[1]):
        longitude = geotransform[0] + x*geotransform[1] + y*geotransform[2]
        latitude = geotransform[3] + x*geotransform[4] + y*geotransform[5]
        elev = elevation[y, x]
        row.append((elev, longitude, latitude))
    matrix.append(row)

# Convert the list to a NumPy array for more efficient operations and handling
matrix_np = np.array(matrix)


# Assuming `elevation` contains your elevation data as a 2D NumPy array
plt.figure(figsize=(10, 10))
plt.imshow(elevation, cmap='terrain')
plt.colorbar(label='Elevation (m)')
plt.title('DEM Elevation Map')
plt.xlabel('Longitude Index')
plt.ylabel('Latitude Index')
plt.show()

def get_data_at_index(matrix, lon_index, lat_index):
    """
    Retrieve elevation, longitude, and latitude data for a specific pixel in the matrix.
    
    Parameters:
    - matrix: The data matrix containing tuples of (elevation, longitude, latitude).
    - lon_index: The longitude index of the pixel.
    - lat_index: The latitude index of the pixel.
    
    Returns:
    - A tuple containing the elevation, longitude, and latitude of the specified pixel, or None if indices are out of bounds.
    """
    # Check if the provided indices are within the bounds of the matrix
    if lat_index >= 0 and lat_index < len(matrix) and lon_index >= 0 and lon_index < len(matrix[0]):
        return matrix[lat_index][lon_index]
    else:
        return None
    
# Assuming matrix_np is your structured NumPy matrix with (elevation, longitude, latitude) for each cell
# First, let's extract the elevation data
elevation_data = [[cell[0] for cell in row] for row in matrix_np]

# Extract longitude and latitude values for headers
# For longitude, take the values from the first row
longitude_values = [cell[1] for cell in matrix_np[0]]  # Assuming all rows have the same longitude values across

# For latitude, take the latitude value of the last cell in each row
latitude_values = [row[-1][2] for row in matrix_np]  # Assuming all columns have the same latitude values down

# Convert elevation data into a DataFrame
df_direct_headers = pd.DataFrame(elevation_data, columns=longitude_values)

# Add latitude values as the first column of the DataFrame
df_direct_headers.insert(0, 'Latitude', latitude_values)

# Save the DataFrame to a CSV file
# csv_path_direct = 'C:/Users/leeyj/lab_ws/source'
df_direct_headers.to_csv('NK_DEM.csv', index=False)

# Note: Replace 'path/to/your/elevation_matrix_direct_headers.csv' with your desired file path
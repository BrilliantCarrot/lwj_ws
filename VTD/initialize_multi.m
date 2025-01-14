%% PSO parameter
num_particles = 200;  % particle number  %% 788 기준 140,  1024-1024 기준 200 (복잡한 지형에서 최적성을 보장하기 위해 증가시킴)
num_waypoints = 6;
num_dimensions = 1;  % (-1, 1)
dimensionality = num_waypoints * num_dimensions;
max_iter = 15000;  
w = 0.5;
c1 =2;
c2 =2;

dist_sampling = 1; 

%% map info

map_size = size(heightmap_gray);
height2zaxis=length(heightmap_gray)/255;


%% initialize
vertical_length_st = 120 ;  %% 1024-1024 기준 120 ,   788 기준 80

height_start = heightmap_gray(round(Start(1)), round(Start(2))); % height cal
height_goal = heightmap_gray(round(Goal(1)), round(Goal(2))); % height cal

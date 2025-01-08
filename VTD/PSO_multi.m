
function  [cal_time, final_waypoints, gBest_value,vertical_length_st]=PSO_multi(heightmap_RGB,Start,Goal)
%%
tic


%%

R(:,:) = double(heightmap_RGB(1:end,:,1));
G(:,:) = double(heightmap_RGB(1:end,:,2));
B(:,:) = double(heightmap_RGB(1:end,:,3));
heightmap_gray(:,:) = (R*0.2989 + G*0.5870 + B*0.1140);

%%
run("initialize_multi.m")


%% PSO

x = rand(num_particles, dimensionality) .* 2 - 1; % particle init pos boundary : [0, map_size] 
v = zeros(num_particles, dimensionality); 
pBest = x;

% [panalty] = panalty_cal(x, waypoints, wp, num_particles, Goal);

[pBest_value] = pBest_cal(Start, Goal, x, num_particles, num_waypoints, dist_sampling, heightmap_gray, vertical_length_st);

[~, idx] = min(pBest_value);
gBest = pBest(idx, :);
gBest_value = pBest_value(idx);

for iter = 1:max_iter
    r1 = rand(num_particles, dimensionality);
    r2 = rand(num_particles, dimensionality);
    v = w * v + c1 * r1 .* (pBest - x) + c2 * r2 .* (gBest - x); % v update

    x = x + v; % x update
    % l = length(x(1,:));
    x(:,:) = max(-1, min(1, x(:,:)));
    % x(:,l/2+1:l) = max(1, min(map_size(2), round(x(:,l/2+1:l))));

    [current_value] = pBest_cal(Start, Goal, x, num_particles, num_waypoints, dist_sampling, heightmap_gray, vertical_length_st);

    update_idx = current_value < pBest_value;
    pBest(update_idx, :) = x(update_idx, :);
    pBest_value(update_idx) = current_value(update_idx);
    
    [min_value, idx] = min(pBest_value);
    if min_value < gBest_value
        gBest = pBest(idx, :);
        gBest_value = min_value;
    end

    end_condition = pBest_value - gBest_value;
    if sum(abs(end_condition)) <=0.5
        break
    end
end

cal_time = toc;

%%
vec_straight_2D = Goal - Start;
Start_height = heightmap_gray(round(Start(1)), round(Start(2))) * height2zaxis;
Goal_height = heightmap_gray(round(Goal(1)), round(Goal(2))) * height2zaxis;
distance_straight_2D = norm(vec_straight_2D);
distance_straight_3D = norm([Start, Start_height] - [Goal, Goal_height]);
%%..start-goal vertical line
vec_vertical = [-vec_straight_2D(2), vec_straight_2D(1)]/distance_straight_2D;
vertical_length = gBest * vertical_length_st;
for k = 1:num_waypoints
    standard_point(k,:) = Start + (Goal - Start) * (k/(num_waypoints+1));
    waypoints(k,:) = standard_point(k,:) + vertical_length(k)*vec_vertical;
end

disp(iter)

%%
final_waypoints = zeros(num_waypoints+2, 2);
final_waypoints(2:end-1,:) = waypoints; % Save the best waypoint for this segment
final_waypoints(1,:) = Start;
final_waypoints(end,:) = Goal;


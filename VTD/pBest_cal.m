%% 기존 버전
% function [pBest_value] = pBest_cal(Start, Goal, x, num_particles, num_waypoints, dist_sampling, heightmap_gray, length_vertical_st)
% %%..start-goal line info
% vec_straight_2D = Goal - Start;
% height2zaxis = length(heightmap_gray)/255;
% 
% Start_height = heightmap_gray(round(Start(1)), round(Start(2))) * height2zaxis;
% Goal_height = heightmap_gray(round(Goal(1)), round(Goal(2))) * height2zaxis;
% dist_straight_2D = norm(vec_straight_2D);
% dist_straight_3D = norm([Start, Start_height] - [Goal, Goal_height]);
% 
% %%..start-goal vertical line
% vec_vertical = [-vec_straight_2D(2), vec_straight_2D(1)]/dist_straight_2D;
% 
% %%..pBest reset
% pBest_value = zeros(num_particles, 1);
% 
% for i = 1:num_particles
%     length_vertical = x(i, :) * length_vertical_st;
%     standard_point = zeros(num_waypoints,2);
%     waypoint = zeros(num_waypoints,2);
%     for k = 1:num_waypoints
%         standard_point(k,:) = Start + (Goal - Start) * (k / (num_waypoints + 1));
%         waypoint(k,:) = standard_point(k,:) + length_vertical(k)*vec_vertical;
%         waypoint(k,1) = max(1,min(waypoint(k,1),length(heightmap_gray)));
%         waypoint(k,2) = max(1,min(waypoint(k,2),length(heightmap_gray)));
%     end
% 
%     dist_total = 0;
% 
%     waypoint=cat(1,Start,waypoint);
%     waypoint(end+1,:)=Goal;
%     for wp = 1:length(waypoint)-1
% 
%         height1 = heightmap_gray(round(waypoint(wp, 1)),round(waypoint(wp, 2))) * height2zaxis;
%         height2 = heightmap_gray(round(waypoint(wp+1, 1)),round(waypoint(wp+1, 2))) * height2zaxis;
%         dist_3D = norm([waypoint(wp+1,:), height2] - [waypoint(wp,:), height1]);
%         dist_total = dist_total + dist_3D;
% 
%     end
% 
%     ratio_dist = dist_total / dist_straight_3D;
%     pBest_value(i) = ratio_dist;
% end
% end


%% 보간점 버전
function [pBest_value] = pBest_cal(Start, Goal, x, num_particles, num_waypoints, dist_sampling, heightmap_gray, length_vertical_st)
    %%..start-goal line info
    vec_straight_2D = Goal - Start;
    height2zaxis = length(heightmap_gray) / 255;
    Start_height = heightmap_gray(round(Start(1)), round(Start(2))) * height2zaxis;
    Goal_height = heightmap_gray(round(Goal(1)), round(Goal(2))) * height2zaxis;
    dist_straight_2D = norm(vec_straight_2D);
    dist_straight_3D = norm([Start, Start_height] - [Goal, Goal_height]);
    %%..start-goal vertical line
    vec_vertical = [-vec_straight_2D(2), vec_straight_2D(1)] / dist_straight_2D;
    %%..pBest reset
    pBest_value = zeros(num_particles, 1);

    % Number of interpolation points between waypoints
    num_interp = 10;

    for i = 1:num_particles
        length_vertical = x(i, :) * length_vertical_st;
        standard_point = zeros(num_waypoints, 2);
        waypoint = zeros(num_waypoints, 2);
        for k = 1:num_waypoints
            standard_point(k,:) = Start + (Goal - Start) * (k / (num_waypoints + 1));
            waypoint(k,:) = standard_point(k,:) + length_vertical(k) * vec_vertical;
            waypoint(k,1) = max(1, min(waypoint(k,1), length(heightmap_gray)));
            waypoint(k,2) = max(1, min(waypoint(k,2), length(heightmap_gray)));
        end

        % Add Start and Goal to waypoints
        waypoint = cat(1, Start, waypoint);
        waypoint(end + 1, :) = Goal;

        dist_total = 0;

        % 전체 보간된 경로를 저장할 배열
        all_points = [];

        % Start 점 추가
        all_points = [all_points; Start];

        % 각 waypoint 쌍 사이의 보간점 생성
        for wp = 1:length(waypoint)-1
            % 현재 waypoint 쌍에 대한 보간점 생성
            for j = 1:num_interp
                t = j / (num_interp + 1);
                interp_point = waypoint(wp,:) * (1-t) + waypoint(wp+1,:) * t;
                all_points = [all_points; interp_point];
            end
        end

        % 마지막 Goal 점 추가
        all_points = [all_points; Goal];

        % 전체 보간된 경로에 대해 연속적으로 3D 거리 계산
        dist_total = 0;
        for j = 1:size(all_points,1)-1
            p1 = all_points(j,:);
            p2 = all_points(j+1,:);

            % Ensure points are within heightmap bounds
            p1 = max(1, min(p1, length(heightmap_gray)));
            p2 = max(1, min(p2, length(heightmap_gray)));

            % Get heights for points
            height1 = heightmap_gray(round(p1(1)), round(p1(2))) * height2zaxis;
            height2 = heightmap_gray(round(p2(1)), round(p2(2))) * height2zaxis;

            % Calculate 3D distance
            dist_total = dist_total + norm([p2-p1, height2-height1]);
        end

        % Calculate path ratio and apply reward structure
        path_ratio = dist_total / dist_straight_3D;
        if path_ratio >= 3.0
            % Penalty for highly inefficient paths
            reward = -200;
        else
            % Reward calculation with an efficiency bonus and a smoothness penalty
            base_reward = 400 * exp(-0.5 * (path_ratio - 1.0));
            efficiency_bonus = 100 * (1.0 - path_ratio / 3.0);
            smoothness_penalty = 0;  % For simplicity, penalty weight is set to zero, adjust if needed
            reward = base_reward + efficiency_bonus * 0 + smoothness_penalty * 0;
        end

        % Store the inverse of reward as pBest_value for minimization
        pBest_value(i) = path_ratio;
    end
end
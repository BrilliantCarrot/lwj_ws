function visibility_matrix = LOS_test(radar_pos, X, Y, Z)
    % radar_pos: [x, y, z] 의 레이더 좌표
    % X, Y, Z: 레이더가 바라보는 각 지형의 좌표 및 고도 
    % visibility_matrix: 가시성 유무가 담긴 행렬

    radar_1 = radar_pos;
    radar_x = radar_1(1);
    radar_y = radar_1(2);
    radar_z = radar_1(3);
    visibility_matrix = zeros(size(Z));
    for i = 1:size(Z, 1)    
        for j = 1:size(Z, 2)
            target_x = X(i,j);
            target_y = Y(i,j);
            target_z = Z(i,j);
            num_steps = max(abs(target_x - radar_x), abs(target_y - radar_y));
            los_x = linspace(radar_x, target_x, num_steps);
            los_y = linspace(radar_y, target_y, num_steps);
            los_z = linspace(radar_z, target_z, num_steps);
            is_visible = true;
            for k = 2:num_steps-1
                [~, closest_row] = min(abs(Y(:, 1) - los_y(k)));
                [~, closest_col] = min(abs(X(1, :) - los_x(k)));
                terrain_z = Z(closest_row, closest_col);
                if terrain_z > los_z(k)
                    is_visible = false;
                    break;
                end
            end
            visibility_matrix(i, j) = is_visible;
        end
    end

    figure;
    clf;
    set(gcf, 'Position', [150, 75, 1200, 750]); % [left, bottom, width, height]
    hold on;
    surf(X, Y, Z, visibility_matrix, 'EdgeColor', 'None', 'FaceAlpha', 0.5);
    colormap([1 0 0;0 1 0]);
    colorbar;
    view(-20, 85);
    plot3(los_x, los_y, los_z, 'b-', 'LineWidth', 2);
    scatter3(radar_x, radar_y, radar_z, 50, 'k', 'filled');
    title('LOS Visibility of RADAR');
    xlabel('X [km]');
    ylabel('Y [km]');
    zlabel('Altitude (meters)');
    legend('Terrain', 'LOS Path', 'Radar', 'Target', 'Obstruction');
    view(3);
    grid on;
end

%     % Initialize visibility matrix (1 for visible, 0 for blocked)
%     visibility_matrix = zeros(size(Z));
% 
%     % Radar position
%     radar_1 = radar_pos;
%     radar_x = radar_1(1);
%     radar_y = radar_1(2);
%     radar_z = radar_1(3);
% 
%     % Loop through all cells in the grid
%     for i = 1:size(Z, 1)
%         for j = 1:size(Z, 2)
%             % Target point coordinates
%             target_x = X(i, j);
%             target_y = Y(i, j);
%             target_z = Z(i, j);
% 
%             % Skip the radar's own position
%             if radar_x == target_x && radar_y == target_y
%                 visibility_matrix(i, j) = 1;
%                 continue;
%             end
% 
%             % Generate LOS vector
%             dx = target_x - radar_x;
%             dy = target_y - radar_y;
%             dz = target_z - radar_z;
%             distance = sqrt(dx^2 + dy^2);
% 
%             % Normalize LOS increments
%             num_steps = round(distance); % Number of steps for LOS traversal
%             step_x = dx / num_steps;
%             step_y = dy / num_steps;
%             step_z = dz / num_steps;
% 
%             % Check intermediate points along the LOS
%             is_visible = true;
%             for step = 1:num_steps
%                 % Current LOS point
%                 los_x = radar_x + step * step_x;
%                 los_y = radar_y + step * step_y;
%                 los_z = radar_z + step * step_z;
% 
%                 % Find the closest terrain cell to the LOS point
%                 [~, closest_i] = min(abs(X(:, 1) - los_x));
%                 [~, closest_j] = min(abs(Y(1, :) - los_y));
% 
%                 % Check if terrain blocks the LOS
%                 if Z(closest_i, closest_j) > los_z
%                     is_visible = false;
%                     break;
%                 end
%             end
% 
%             % Update visibility matrix
%             visibility_matrix(i, j) = is_visible;
%         end
%     end
% 
%     % Visualize results
%     figure;
%     clf;
%     set(gcf, 'Position', [150, 75, 1200, 750]); % [left, bottom, width, height]
%     surf(X/1000, Y/1000, Z, visibility_matrix, 'EdgeColor', 'k', 'LineWidth',1);
%     colormap([1 0 0; 0 1 0]); % Red for blocked, Green for visible
%     colorbar('Ticks', [0, 1], 'TickLabels', {'Blocked', 'Visible'});
%     view(-20, 85);
%     grid on;
%     xlabel('X Coordinate');
%     ylabel('Y Coordinate');
%     zlabel('Altitude');
%     title('Plot line of Sight (LOS) of RADAR');
%     view(3);

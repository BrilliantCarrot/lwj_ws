%% MAP Initialize
clear; clc; close all;
% load C:/Users/ThinkYun/lab_ws/data/VTD/Radar/MAP_STRUCT;
load C:/Users/leeyj/lab_ws/data/VTD/Radar/MAP_STRUCT.mat;

% dm = 샘플링 간격, 10
dm = 20; g_size = size(MAP.X,1);
mesh_x = floor(g_size/2)-250:dm:g_size-750;
mesh_y = floor(g_size/2)-370:dm:g_size-540;

X1 = MAP.X(mesh_x,mesh_y);
Y1 = MAP.Y(mesh_x,mesh_y);
X = X1 - min(min(X1));
Y = Y1 - Y1(1,1);
Z = MAP.alt(mesh_x,mesh_y);

%% RADAR Initialize
load C:/Users/leeyj/lab_ws/data/VTD/Radar/Results_2GHz.mat
RADAR.RCS1 = Sth;
RADAR.theta = theta;
RADAR.psi = psi;
load C:/Users/leeyj/lab_ws/data/VTD/Radar/Results_8GHz.mat
RADAR.RCS2 = Sth;

%% Trajectory
x0 = 34000; y0 = 37400;
[ix, iy] = pos2grid(x0,y0,X,Y);
% ix = 80; iy = 40;
x = X(ix,iy); y = Y(ix,iy); z =  Z(ix,iy);
dt = 0.1;
vx = 0; vy = 0; vz = 0;
traj = [x y z vx vy vz];
k = 2;

for t = 0:dt:11
    vz = 10;
    if z > Z(ix,iy) + 100
        vz = 0;
    end
    x = x + vx*dt;
    y = y + vy*dt;
    z = z + vz*dt;   

    traj(k,:) = [x y z vx vy vz];
    k = k+1;

end
    alt = 100;
    k = k-1;
for t = 11:dt:190
    vx = -3*60; vy = -3*60;
    x =  x+vx*dt;
    y =  y+vy*dt;
    z = alt + cal_alt(x,y,X,Y,Z);
    traj(k,:) = [x y z vx vy vz];
    k = k+1;
end

%% Cal Visibility
clc;
% 처음 interval, visual_range는 30; 100000;
interval = 50; visual_range = 75000;
LOS_length = 5000; % LOS벡터의 뒤로 연장하여 지형지물 가림을 비교할 거리
visibility_results = false(size(traj, 1), 1); % 가시성 결과 저장
block_check = false;
for i = 1:10:length(traj)
    hx = traj(i,1); hy = traj(i,2); hz = traj(i,3);
    visual_matrix = zeros(length(mesh_x),length(mesh_y));

    for j = 1:length(mesh_x)
        for k = 1:length(mesh_y)

            grid_x = X(j,k); grid_y = Y(j,k);
            if grid_x < 0.1
                grid_x = 0.1;
            end

            if grid_y < 0.1
                grid_y = 0.1;
            end


            if grid_x < hx
                dx = (hx - grid_x)/interval;
                LOSx = grid_x:dx:hx;
            elseif grid_x > hx
                dx = (-hx + grid_x)/interval;
                LOSx = hx:dx:grid_x;
            else
                LOSx = zeros(1,interval+1);
                LOSx(:) = hx;
            end

            if grid_y < hy
                dy = (hy - grid_y)/interval;
                LOSy = grid_y:dy:hy;
            elseif grid_y > hy
                dy = (-hy + grid_y)/interval;
                LOSy = hy:dy:grid_y;
            else
                LOSy = zeros(1,interval+1);
                LOSy(:) = hy;
            end

            threshold_z = max(cal_alt(hx,hy,X,Y,Z),cal_alt(grid_x,grid_y,X,Y,Z));
        
            check_point = 0;
            for check_idx = 1:interval+1
                

                minZ = min(cal_alt(hx,hy,X,Y,Z),cal_alt(grid_x,grid_y,X,Y,Z));
                maxZ = max(cal_alt(hx,hy,X,Y,Z),cal_alt(grid_x,grid_y,X,Y,Z));

                threshold_z = minZ + (maxZ-minZ)*check_idx/interval+1;
                check_alt = cal_alt(LOSx(check_idx),LOSy(check_idx),X,Y,Z);
                if check_alt > threshold_z
                    check_point = check_point + 1;
                    break;
                end
            end
            range = norm([hx-grid_x hy-grid_y]);
            if check_point == 0 && range < visual_range
                visibility = 0;
            else
                visibility = 1;
            end
%             visual_matrix(j,k) = visibility;

            space = 100;
            RADAR.RadarPos(1,:) = [grid_x grid_y cal_alt(grid_x,grid_y,X,Y,Z)];
            % RPos_save(j,k,:) = RADAR.RadarPos(1,:);
            block_check = check_target_behind(RADAR,[hx,hy,hz],X,Y,Z,space,LOS_length);
            % disp(RADAR.RadarPos(1,:));
            % sig1에 SIR_값이 들어감
            % [sig1,sigma_MBc,sigma_SLc,sigma_clutter,SNR,SCR,SIR_dB,Range] = ...
            %     RADAR_Module_SIR(block_check,RADAR,[hx,hy,hz],1,X,Y,Z);
            [sig1,SNR] = RADAR_Module_SNR(RADAR,[hx,hy,hz],1,X,Y,Z);

            % sig1 = 4.5*(sig1-70);

            % sig_save(j,k) = sig1;

            % MBc_save(j,k) = sigma_MBc;
            % SLc_save(j,k) = sigma_SLc;
            % sigma_clutter_save(j,k) = sigma_clutter;
            % SNR_save(j,k) = SNR;
            % SCR_save(j,k) = SCR;
            % SIR_save(j,k) = SIR_dB;
            % Range_save(j,k) = Range;
            % pos_save(j,k) = RADAR.RadarPos(1,3);

            % if sig < 90
            %     if sig < 0 
            %         sig = 0;
            %     end
            %     C(j,k,1) = 0;           % C에 색깔 정보(가시 유무)가 저장됨
            %     C(j,k,2) = sind(sig);
            %     C(j,k,3) = cosd(sig);
            % else
            %     if sig  > 180
            %         sig = 180;
            %     end
            %     C(j,k,1) = sind(sig-90);
            %     C(j,k,2) = cosd(sig-90);
            %     C(j,k,3) = 0;
            % end
            % if visibility == 1  % 기체가 레이더에 안 보이게 된다면 회색으로 처리
            %     C(j,k,1) = 0.5;
            %     C(j,k,2) = 0.5;
            %     C(j,k,3) = 0.5;
            % end

            % MTI Loss와 CFAR Loss도 구하면 15.14dB보다 높은 값이 나와야됨
            
            if visibility == 1 % 기체가 레이더에 안 보이게 된다면 회색으로 처리
                sig_save(j,k) = 0;  % 0이 아닌 다른 설정 필요
            else
                sig_save(j,k) = sig1;
            end
        end
    end
    % Visual_Struct{i} = visual_matrix;
    % RADAR_sig_SNR{i} = sig_save;    % 가시 여부를 고려 안하고 SIR만 적용된 원래 칼라맵
    RADAR_sig_SIR{i} = sig_save;
    % MBc_mat{i} = MBc_save;
    % SLc_mat{i} = SLc_save;
    % sigma_clutter_mat{i} = sigma_clutter_save;
    % SNR_mat{i} = SNR_save;
    % SCR_mat{i} = SCR_save;
    % SIR_mat{i} = SIR_save;
    % Range_mat{i} = Range_save;
    % RPos_mat{i} = RPos_save;
    % pos_mat{i} = pos_save;

    % RADAR_C_SIR{i} = C;
    % RADAR_C{i} = C;             % 가시 여부가 반영된 신호 칼라맵
end

%% 시각화

figure(1)
set(gcf, 'Position', [150, 75, 1200, 750]); % [left, bottom, width, height]
clf
pause(1)
for i = 1:10:length(traj)                                                           
    s = surf(X, Y, Z, real(RADAR_sig_SIR{i})); hold on;
    plot3(traj(1:i,1)/1000, traj(1:i,2)/1000, traj(1:i,3), '-', 'Color', 'k', 'LineWidth', 2); hold on; grid on;

    xlabel('X [km]');
    ylabel('Y [km]');
    zlabel('Altitude [m]');
    alpha(s, 0.5);
    view(-20, 85);
    % clim([min(RADAR_sig_SIR{i}(:)), max(RADAR_sig_SIR{i}(:))]);
    % c = colorbar;
    % c.Label.String = 'RADAR Signal (SIR in dB)';
    pause(1);
    if i < length(traj)
        delete(s);
    end
end

%% 레이더를 특정 위치에 고정시킨 후 전체 지형에 대해 SIR을 구하는 코드

radar_1 = [20000, 20000, 300];  % 레이더1 위치
% radar_2 = [14000, 14000, 300];  % 레이더2 위치

clc;
SIR_matrix = RADAR_loc_sim(radar_1, X, Y, Z, RADAR);

%% 시각화

figure;
set(gcf, 'Position', [150, 75, 1200, 750]); % [left, bottom, width, height]
clf;
s = surf(X / 1000, Y / 1000, Z, SIR_matrix, 'EdgeColor', 'k', 'LineWidth',1);
hold on;
plot3(radar_1(1) / 1000, radar_1(2) / 1000, radar_1(3), ...
      'ko', 'MarkerSize', 15, 'MarkerFaceColor', 'k', 'LineWidth', 2);
xlabel('X [km]');
ylabel('Y [km]');
zlabel('Altitude [m]');
title('SIR Distribution Over Terrain');
colorbar;
colormap(jet);
clim([min(SIR_matrix(:)), max(SIR_matrix(:))]);
c = colorbar;
c.Label.String = 'RADAR Signal (SIR in dB)';
view(-20, 85);
grid on;
alpha(s, 0.8);

%% 생성된 시뮬레이션 맵에서 PSO 알고리즘 이용

clc;
radar_1 = [20000, 20000, 900];  % 단일 레이더의 경우
radars = [20000, 20000, 900];    % 복수의 레이더 경우
start_pos = [34000, 37400, 770];
% end_pos = [1780, 5180, 450];
end_pos = [1710,5170,420];
interval = 50;
% path = PSO_SIR_Optimization(radar_1, start_pos, end_pos, X, Y, Z, RADAR);
[path, sir_data] = PSO_SIR_Optimization(radars, start_pos, end_pos, X, Y, Z, RADAR, interval);

%% PSO 결과 시각화

clc;
close all;
visualize_PSO_SIR(path, sir_data, radar_1, X, Y, Z);

% figure;
% set(gcf, 'Position', [200, 100, 1000, 750]);
% s = surf(X / 1000, Y / 1000, Z, 'EdgeColor', 'none');
% hold on;
% plot3(path(:, 1) / 1000, path(:, 2) / 1000, path(:, 3), 'r-', 'LineWidth', 2);
% plot3(radar_1(1) / 1000, radar_1(2) / 1000, radar_1(3), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
% xlabel('X [km]');
% ylabel('Y [km]');
% zlabel('Altitude [m]');
% title('Optimized Path Visualization');
% colorbar;
% colormap(jet);
% view(-20, 80);
% grid on;
% alpha(s, 0.8);
% legend('Terrain', 'Optimized Path', 'Radar Position', 'Location', 'Best');

%%
visualize_los(radar_1,X,Y,Z,50,100000);

%% 

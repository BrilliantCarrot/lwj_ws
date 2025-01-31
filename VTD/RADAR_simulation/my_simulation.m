% 레이더 가시성 테스트 메인 코드
%% 초기화
clear; clc; close all;
load C:/Users/leeyj/lab_ws/data/VTD/RADAR/output_map.mat;
X = MAP.X; % X 좌표
Y = MAP.Y; % Y 좌표
Z = MAP.alt; % 고도
x_min = 0; x_max = 30000;
y_min = 0; y_max = 40000;
% X와 Y 범위에 해당하는 인덱스 계산
x_idx = (X(1, :) >= x_min) & (X(1, :) <= x_max);
y_idx = (Y(:, 1) >= y_min) & (Y(:, 1) <= y_max);
X = double(X(y_idx, x_idx));
Y = double(Y(y_idx, x_idx));
Z = double(Z(y_idx, x_idx));
dx = 10;
dy = 10;
% 자른 간격으로 지형 단순화
X_reduced = X(1:dy:end, 1:dx:end); % X 데이터 축소
Y_reduced = Y(1:dy:end, 1:dx:end); % Y 데이터 축소
Z = Z(1:dy:end, 1:dx:end); % Z 데이터 축소
% 정규화 및 Y 좌표 방향 수정
X = X_reduced - min(min(X_reduced)); % X 좌표를 0부터 시작
Y = Y_reduced - min(min(Y_reduced)); % Y 좌표를 0부터 시작
% 레이더 설정
load C:/Users/leeyj/lab_ws/data/VTD/RADAR/Results_2GHz.mat
RADAR.RCS1 = Sth;
RADAR.theta = theta;
RADAR.psi = psi;
load C:/Users/leeyj/lab_ws/data/VTD/RADAR/Results_8GHz.mat
RADAR.RCS2 = Sth;
RADAR.lambda = freq2wavelen(2 * 10^9); % 기본 2GHz 파라미터
RADAR.Pt = 14000;  % [W] Peak Power
RADAR.tau = 0.00009;  % [s] Pulse Width
RADAR.G = 34;  % [dBi] Antenna Gain
RADAR.Ts = 290;  % [K] System Temperature
RADAR.L = 8.17;  % [dB] Loss
RADAR.sigma_0 = 10^(-20/10);  % Clutter Scattering Coefficient
RADAR.theta_A = deg2rad(1);  % Azimuth Beamwidth
RADAR.theta_E = deg2rad(2);  % Elevation Beamwidth
RADAR.SL_rms = 10^(-20.10);  % RMS Sidelobe Level
RADAR.R_e = 6.371e6;  % Earth Radius (m)
RADAR.c = 3e8;  % Speed of Light (m/s)
RADAR.prf = 1000; % [Hz] Pulse repetition frequency
RADAR.Du = RADAR.tau * RADAR.prf;
rcs_table = RADAR.RCS1;
radar_1 = double([10000, 10000, 230]);  % 레이더1 위치
% radar_2 = [14000, 14000, 300];  % 레이더2 위치
%% 시각화
figure;
clf;
set(gcf, 'Position', [150, 75, 1200, 750]); % [left, bottom, width, height]
s = surf(X/1000, Y/1000, Z, 'EdgeColor', 'k', 'LineWidth',1);
hold on;
plot3(radar_1(1)/1000, radar_1(2)/1000, radar_1(3), ...
      'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k', 'LineWidth', 2);
colormap('jet');
colorbar;
view(20, 85);
grid on;
alpha(s, 0.8);
title('3D Surface');
xlabel('X Coordinate (meters)');
ylabel('Y Coordinate (meters)');
zlabel('Altitude (meters)');
%% 레이더를 특정 위치에 고정시킨 후 전체 지형에 대해 SIR을 구하는 코드
clc; close all;
radar_1 = double(radar_1);
SIR_matrix = RADAR_loc_sim(radar_1, X, Y, Z, RADAR);
figure;
clf;
set(gcf, 'Position', [150, 75, 1200, 750]);
s = surf(X/1000, Y/1000, Z, SIR_matrix, 'EdgeColor', 'k', 'LineWidth',1);
hold on;
plot3(radar_1(1) / 1000, radar_1(2) / 1000, radar_1(3), ...
      'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k', 'LineWidth', 2);
colorbar;
colormap(jet);
view(-20, 85);
grid on;
alpha(s, 0.8);
clim([min(SIR_matrix(:)), max(SIR_matrix(:))]);
c = colorbar;
c.Label.String = 'RADAR Signal (SIR in dB)';
xlabel('X [km]');
ylabel('Y [km]');
zlabel('Altitude [m]');
title('SIR Distribution Over Terrain');
%% 가시성 테스트
% 전체 지형에 대한 가시성 결과 시각화
visibility_matrix = LOS_test_new(radar_1, X, Y, Z);
%% 
figure;
clf;
set(gcf, 'Position', [150, 75, 1200, 750]);
hold on;
surf(X, Y, Z, visibility_matrix, 'EdgeColor', 'k', 'LineWidth', 1, 'FaceAlpha', 0.5);
colormap([1 0 0;0 1 0]);
colorbar;
view(-20, 85);
scatter3(radar_1(1), radar_1(2), radar_1(3), 50, 'k', 'filled');
title('LOS Visibility of RADAR');
xlabel('X [km]');
ylabel('Y [km]');
zlabel('Altitude (meters)');
legend('Terrain', 'Radar');
grid on;
%%
% 가시성이 없는 영역을 NaN으로 설정하여 회색으로 표현
SIR_display = SIR_matrix;
SIR_display(visibility_matrix == 0) = NaN;
figure;
clf;
set(gcf, 'Position', [150, 75, 1200, 750]);
hold on;
% 가시성 있는 영역의 SIR 값 표시
s = surf(X, Y, Z, SIR_display, 'EdgeColor', 'k', 'LineWidth', 1); % 가시성 영역에 대해 색상 적용
colormap('jet');
colorbar;
clim([min(SIR_matrix(:)), max(SIR_matrix(:))]);
% 가시성이 없는 영역을 회색으로 표시
gray_mask = surf(X, Y, Z, 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none'); 
set(gray_mask, 'FaceAlpha', 0.6); % 투명도 설정하여 구분 가능하도록 함
scatter3(radar_1(1), radar_1(2), radar_1(3), 100, 'k', 'filled');
view(-20, 85);
grid on;
title('SIR Visualization with LOS Constraint');
xlabel('X [km]');
ylabel('Y [km]');
zlabel('Altitude (meters)');
legend('Visible Terrain SIR', 'Non-visible Terrain (Gray)', 'Radar');
%% 특정 지역의 가시성 결과 시각화
% target_1 = double([15869.5, 4359.59, 190]);
% LOS_test_single(radar_1,target_1,X,Y,Z);
%% PSO 
% clc;
% radar_1 = [10000, 10000, 230]; % 단일 레이더의 경우
% radars = [10000, 10000, 230]; % 복수의 레이더 경우
% start_pos = [0, 0, 200];
% % end_pos = [1780, 5180, 450];
% end_pos = [25000,34000,80];
% % path = PSO_SIR_Optimization(radar_1, start_pos, end_pos, X, Y, Z, RADAR);
% [path, sir_data] = PSO_SIR_Optimization(radars, start_pos, end_pos, X, Y, Z, RADAR);
%% 가시성까지 고려된 환경에서 PSO 테스트
clc;
radar_1 = [10000, 10000, 230]; % 단일 레이더의 경우
radars = [10000, 10000, 230]; % 복수의 레이더 경우
start_pos = [0, 0, 200];
% end_pos = [1780, 5180, 450];
end_pos = [25000,34000,80];
% path = PSO_SIR_Optimization(radar_1, start_pos, end_pos, X, Y, Z, RADAR);
[path, sir_data] = PSO_visibility(radars, start_pos, end_pos, X, Y, Z, RADAR,visibility_matrix);
%%
visualize_PSO_SIR(path, sir_data, radar_1, X, Y, Z);
%%
clear; clc; close all;
waypoints = path;
num_waypoints = size(waypoints, 1);
dt = 0.1;  % 시뮬레이션 타임 스텝 [s]
T_end = 100; % 최대 시뮬레이션 시간 [s]
t = 0:dt:T_end;
num_steps = length(t);
state = zeros(num_steps, 12); % [x, y, z, u, v, w, phi, theta, psi, p, q, r]
state(1, 1:3) = waypoints(1, :); % 초기 위치 설정
% 초기 속도 설정 (웨이포인트 간 평균 속도)
avg_speed = 50; % m/s (기본 설정)
state(1, 4:6) = [avg_speed, 0, 0];
m = 1000; % 질량 [kg]
g = 9.81; % 중력가속도 [m/s^2]
I = diag([5000, 5000, 8000]); % 관성 모멘트 행렬 [kg*m^2]
for i = 1:num_steps-1
    % 현재 상태
    pos = state(i, 1:3);
    vel = state(i, 4:6);
    euler = state(i, 7:9);
    omega = state(i, 10:12);
    
    % 목표 웨이포인트 결정
    target_idx = min(find(vecnorm(waypoints - pos, 2, 2) > 10, 1), num_waypoints);
    target = waypoints(target_idx, :);
    
    % 속도 방향 업데이트
    dir_vector = (target - pos) / norm(target - pos);
    speed = norm(vel);
    new_vel = dir_vector * speed;
    
    % 중력 및 단순 제어 입력 적용
    F_thrust = m * g + 500; % 기본 양력 + 추가 추력
    F_body = [F_thrust; 0; 0]; % 비행기 진행 방향으로 힘 작용
    M_body = [0; 0; 0]; % 초기 제어 입력 없음
    
    % 운동 방정식 (뉴턴-오일러)
    acc = F_body / m - [0; 0; g];
    omega_dot = I \ (M_body - cross(omega, I * omega));
    
    % 상태 업데이트 (오일러 적분)
    state(i+1, 1:3) = pos + vel * dt;
    state(i+1, 4:6) = vel + acc' * dt;
    state(i+1, 7:9) = euler + omega * dt;
    state(i+1, 10:12) = omega + omega_dot' * dt;
end
%% 결과 시각화
figure;
plot3(state(:,1), state(:,2), state(:,3), 'b-', 'LineWidth', 2);
hold on;
scatter3(waypoints(:,1), waypoints(:,2), waypoints(:,3), 50, 'ro', 'filled');
grid on;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Altitude (m)');
title('6-DoF Aircraft Simulation Following Waypoints');
legend('Flight Path', 'Waypoints');
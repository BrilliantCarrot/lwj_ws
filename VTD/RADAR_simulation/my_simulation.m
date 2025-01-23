clear; clc; close all;
load C:/Users/ThinkYun/lab_ws/data/VTD/Radar/output_map.mat;
X = MAP.X; % X 좌표
Y = MAP.Y; % Y 좌표
Z = MAP.alt; % 고도
% 지형 전처리
% X와 Y의 중간 영역 선택 (-20000 ~ +20000), 시뮬레이션 속도 향상을 위함
x_min = 0; x_max = 30000;
y_min = 0; y_max = 40000;
% X와 Y 범위에 해당하는 인덱스 계산
x_idx = (X(1, :) >= x_min) & (X(1, :) <= x_max);
y_idx = (Y(:, 1) >= y_min) & (Y(:, 1) <= y_max);
X = X(y_idx, x_idx);
Y = Y(y_idx, x_idx);
Z = Z(y_idx, x_idx);
dx = 20; % X축 간격
dy = 20; % Y축 간격
% 자른 간격으로 지형 단순화
X_reduced = X(1:dy:end, 1:dx:end); % X 데이터 축소
Y_reduced = Y(1:dy:end, 1:dx:end); % Y 데이터 축소
Z = Z(1:dy:end, 1:dx:end); % Z 데이터 축소
% 정규화 및 Y 좌표 방향 수정
X = X_reduced - min(min(X_reduced)); % X 좌표를 0부터 시작
Y = Y_reduced - min(min(Y_reduced)); % Y 좌표를 0부터 시작
%% 레이더 설정
load C:/Users/ThinkYun/lab_ws/data/VTD/Radar/Results_2GHz.mat
RADAR.RCS1 = Sth;
RADAR.theta = theta;
RADAR.psi = psi;
load C:/Users/ThinkYun/lab_ws/data/VTD/Radar/Results_8GHz.mat
RADAR.RCS2 = Sth;
% 레이더 파라미터 설정
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
radar_1 = [10000, 10000, 220];  % 레이더1 위치

%% 시각화

figure;
clf;
set(gcf, 'Position', [150, 75, 1200, 750]); % [left, bottom, width, height]
s = surf(X/1000, Y/1000, Z, 'EdgeColor', 'k', 'LineWidth',1);
hold on;
plot3(radar_1(1)/1000, radar_1(2)/1000, radar_1(3), ...
      'ko', 'MarkerSize', 15, 'MarkerFaceColor', 'k', 'LineWidth', 2);
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
% radar_2 = [14000, 14000, 300];  % 레이더2 위치
radar_1 = double(radar_1);
SIR_matrix = RADAR_loc_sim(radar_1, X, Y, Z, RADAR);

figure;
clf;
set(gcf, 'Position', [150, 75, 1200, 750]); % [left, bottom, width, height]
s = surf(X/1000, Y/1000, Z, SIR_matrix, 'EdgeColor', 'k', 'LineWidth',1);
hold on;
plot3(radar_1(1) / 1000, radar_1(2) / 1000, radar_1(3), ...
      'ko', 'MarkerSize', 15, 'MarkerFaceColor', 'k', 'LineWidth', 2);
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

%%




% % 2D 색상으로 자른 데이터 시각화
% figure;
% contourf(X_crop, Y_crop, Z_crop, 100, 'LineStyle', 'none'); % 2D 등고선 색상 시각화
% colormap('parula'); % 색상 지도 설정
% colorbar; % 색상 막대 추가
% caxis([min(Z_crop(:)), max(Z_crop(:))]); % 고도 범위로 색상 제한 설정
% 
% % 그래프 레이블 및 제목
% xlabel('X Coordinate (meters)');
% ylabel('Y Coordinate (meters)');
% title('Lambert Conformal Conic Projection of DEM - Cropped 2D View');




% % 간격에 따른 축소된 지형 데이터 생성
% X_reduced = X_crop(1:dy:end, 1:dx:end);
% Y_reduced = Y_crop(1:dy:end, 1:dx:end);
% Z_reduced = Z_crop(1:dy:end, 1:dx:end);
% 
% % 3D 시각화 - surf
% figure;
% surf(X_reduced, Y_reduced, Z_reduced, 'EdgeColor', 'none');
% colormap('jet');
% colorbar;
% title('Reduced Terrain Data - 3D Surface');
% xlabel('X Coordinate (meters)');
% ylabel('Y Coordinate (meters)');
% zlabel('Elevation (meters)');
% grid on;



% Y = Y_reduced - Y_reduced(1, 1); % Y 좌표를 기준점(1,1)에서 시작
% Y = max(max(Y)) - Y; % Y 방향 반전



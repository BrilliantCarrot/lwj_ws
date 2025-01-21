% MATLAB 코드
% x-y 축 범위 설정
x = 0:1:100;
y = 0:1:100;

% 임의 지형 생성 (surf와 peak 함수를 사용)
[X, Y] = meshgrid(x, y);
Z = 10 * peaks(101);  % 고도 데이터
Z(Z < 0) = 0;        % 음수 값 제거

% 특정 점 설정 (관측점)
obs_x = 50;  % x 좌표
obs_y = 50;  % y 좌표
obs_z = 20; % 고도

% 시각화를 위한 figure 초기화
figure;
surf(X, Y, Z, 'EdgeColor', 'none');
hold on;
colormap('parula');

% 특정 점 시각화
plot3(obs_x, obs_y, obs_z, 'ro', 'MarkerSize', 10, 'LineWidth', 2);

% 각 셀에 대해 선 (LOS 벡터) 생성 및 차단 확인
for i = 1:size(X, 1)
    for j = 1:size(X, 2)
        % 현재 셀 좌표
        cell_x = X(i, j);
        cell_y = Y(i, j);
        cell_z = Z(i, j);

        % 관측점과 현재 셀 간의 LOS 벡터 계산
        vec_x = linspace(obs_x, cell_x, 100);
        vec_y = linspace(obs_y, cell_y, 100);
        vec_z = linspace(obs_z, cell_z, 100);

        % LOS 벡터가 지형에 의해 차단되었는지 확인
        is_blocked = false;
        for k = 1:length(vec_x)
            % 각 LOS 지점의 x, y, z 값
            px = vec_x(k);
            py = vec_y(k);
            pz = vec_z(k);

            % 지형 고도 (Z 데이터)와 비교
            if interp2(X, Y, Z, px, py) > pz
                is_blocked = true;
                break;
            end
        end

        % 차단되지 않은 경우에만 선을 그림
        if ~is_blocked
            plot3([obs_x, cell_x], [obs_y, cell_y], [obs_z, cell_z], 'b');
        end
    end
end

% 시각화 옵션
xlabel('X-axis'); ylabel('Y-axis'); zlabel('Elevation');
title('Line of Sight (LOS) with Terrain Blocking');
grid on;
hold off;


% % 임의 지형 데이터를 생성하고 DTED 데이터를 대신하여 사용
% 
% % 1. 임의 지형 데이터 생성
% x = linspace(-100, 100, 100); % X축 범위 및 분할
% y = linspace(-100, 100, 100); % Y축 범위 및 분할
% [X, Y] = meshgrid(x, y);
% Z = 100 * exp(-0.1 * (X.^2 + Y.^2)) + 10 * sin(0.5 * X) .* cos(0.5 * Y); % 고도 데이터 생성
% 
% % 생성한 데이터를 구조체로 저장
% map.x = X;
% map.y = Y;
% map.z = Z;
% 
% % 2. 격자 생성 (dx와 dy를 설정하여 일정 간격으로 분할)
% latlim = [-100, 100]; % 가상의 위도 범위
% lonlim = [-100, 100]; % 가상의 경도 범위
% 
% % dx와 dy 설정 (예: 1 단위 간격)
% dx = 1;
% dy = 1;
% 
% [lonGrid, latGrid] = meshgrid(linspace(lonlim(1), lonlim(2), size(Z, 2)), ...
%                               linspace(latlim(1), lonlim(2), size(Z, 1)));
% 
% % 3. 특정 점 기준 설정 (예: 중앙점 사용)
% center_lat = -5;
% center_lon = -5;
% center_height = 20;
% 
% % 4. LOS 벡터 계산 및 시각화
% figure;
% surf(map.x, map.y, map.z, 'EdgeColor', 'none');
% colormap(parula); % terrain 대신 parula로 대체
% shading interp;
% hold on;
% 
% % LOS 벡터 그리기
% for i = 1:10:size(Z, 1) % 간격 조정 가능
%     for j = 1:10:size(Z, 2) % 간격 조정 가능
%         % 현재 셀의 좌표
%         target_lat = latGrid(i, j);
%         target_lon = lonGrid(i, j);
%         target_height = Z(i, j);
% 
%         % LOS 경로 중간 체크 (차단 여부 확인)
%         los_blocked = false;
%         num_points = 1000; % 경로를 따라 확인할 점의 개수
%         for t = linspace(0, 1, num_points)
%             intermediate_lat = center_lat + t * (target_lat - center_lat);
%             intermediate_lon = center_lon + t * (target_lon - center_lon);
%             intermediate_height = center_height + t * (target_height - center_height);
% 
%         % interp2에 외삽 옵션 추가
%         actual_height = interp2(lonGrid, latGrid, Z, intermediate_lon, intermediate_lat, 'linear', NaN);
% 
%         % NaN 값 필터링
%         if isnan(actual_height)
%             continue; % 현재 경로 점을 건너뜀
%         end
% 
%         % 현재 경로에서의 예상 고도와 실제 고도를 비교
%         if actual_height > intermediate_height
%             los_blocked = true;
%             break;
%         end
%         end
% 
% % 차단되지 않은 경우에만 선을 그리기
% if ~los_blocked
%     line([center_lon, target_lon], [center_lat, target_lat], ...
%          [center_height, target_height], 'Color', 'r');
% end
%     end
% end
% 
% % 5. 축 설정 및 보기 조정
% xlabel('Longitude');
% ylabel('Latitude');
% zlabel('Height (m)');
% grid on;
% axis tight;
% title('임의 지형 데이터와 LOS 벡터 시각화');
% hold off;


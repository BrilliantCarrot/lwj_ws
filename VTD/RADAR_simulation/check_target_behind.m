function is_blocked = check_target_behind(PosN, X, Y, Z, interval,LOS_length)
    % PosN: 목표물 위치 [x, y, z]
    % X, Y, Z: 지형 데이터 (각각 x, y, z 좌표 행렬)
    % interval: 샘플링 간격
    % LOS_length: LOS 벡터 길이 (단위: m)

    % 초기값
    is_blocked = false(size(X)); % 모든 셀에 대한 가려짐 여부 저장
    
    % 모든 셀에 대해 반복
    for row = 1:size(X, 1)
        for col = 1:size(X, 2)
            % 현재 셀의 레이더 위치
            radar_pos = [X(row, col), Y(row, col), Z(row, col)];

            % LOS 벡터 계산
            LOS_direction = (PosN - radar_pos) / norm(PosN - radar_pos); % 단위 벡터
            
            % 샘플링 포인트 생성
            num_points = ceil(LOS_length / interval); % 샘플링 점 수
            for i = 1:num_points
                current_point = PosN + (i * interval) * LOS_direction; % 샘플링된 LOS 점
                x = current_point(1);
                y = current_point(2);
                z = current_point(3);

                % 현재 점에 가장 가까운 지형 셀의 인덱스 계산
                [~, ix] = min(abs(X(1,:) - x)); % x축에서 가장 가까운 셀
                [~, iy] = min(abs(Y(:,1) - y)); % y축에서 가장 가까운 셀

                % 지형 고도 가져오기
                if ix > 0 && ix <= size(X, 2) && iy > 0 && iy <= size(Y, 1)
                    terrain_alt = Z(iy, ix);

                    % 지형 고도가 LOS 벡터의 고도보다 높으면 가려짐으로 판단
                    if terrain_alt > z
                        is_blocked(row, col) = true; % 현재 셀에서 가려짐
                        break; % 더 이상 확인하지 않음
                    end
                end
            end
        end
    end
end


% function is_blocked = check_target_behind(RADAR, PosN, X, Y, Z, interval)
%     % RADAR: 레이더 정보 구조체
%     % PosN: 목표 비행체 위치 [x, y, z]
%     % X, Y, Z: 지형 데이터
%     % interval: 샘플링 간격
% 
%     % 레이더와 목표 간 LOS 벡터 계산
%     RelPos = - RADAR.RadarPos(1,:) + PosN;      % 레이더에서 목표로의 상대 위치
%     LOS_direction = RelPos / norm(RelPos);      % 단위 벡터로 정규화
% 
%     % 목표 비행체의 뒤쪽으로 LOS 벡터를 확장
%     LOS_length = 50000;    % 최대 탐색 거리 -> 100000;
%     num_points = ceil(LOS_length / interval);   % 샘플링 포인트 수
%     % fprintf("num_points: %d  ", num_points);
% 
%     % LOS_points = zeros(num_points, 3);          % 샘플링된 점들 저장
%     % for i = 1:num_points
%     %     LOS_points(i, :) = PosN + (i * interval) * LOS_direction;
%     %     % fprintf("LOS_Points: x = %f, y = %f, z = %f\n", LOS_points(i, 1), LOS_points(i, 2), LOS_points(i, 3));
%     % end
% 
%     % LOS 벡터 고도와 LOS 벡터와 가장 가까운 지역의 고도를 비교
%     is_blocked = false;
%     for i = 1:num_points
%         current_point = PosN + (i * interval) * LOS_direction;       % 현재 샘플링된 점 [x, y, z]
%         x = current_point(1);
%         y = current_point(2);
%         z = current_point(3);
% 
%         % 현재 점에 가장 가까운 지형 셀의 인덱스 계산
%         [~, ix] = min(abs(X(1,:) - x));     % x축에서 가장 가까운 지형 셀
%         [~, iy] = min(abs(Y(:,1) - y));     % y축에서 가장 가까운 지형 셀
% 
%         % 지형 데이터 범위를 벗어난 경우 무시
%         if ix < 1 || ix > size(X, 2) || iy < 1 || iy > size(Y, 1)
%             continue;
%         end
% 
%         terrain_alt = Z(iy, ix);
% 
%         % 해당 위치의 지형 고도 계산
%         % terrain_alt = cal_alt(x, y, X, Y, Z);
% 
%         % 지형 고도가 샘플링된 LOS 점보다 높으면 시야가 막힌 것으로 판단
%         if terrain_alt > z
%             is_blocked = true;
%             return;
%         end
%     end
% end
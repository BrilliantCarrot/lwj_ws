function is_visible = check_visibility(radar_pos, target_pos, X, Y, Z, interval)
    % radar_pos: 레이더 위치 [x, y, z]
    % target_pos: 목표 위치 [x, y, z]
    % X, Y, Z: 지형 데이터
    % interval: 샘플링 간격


    % 초기값
    is_visible = true; % 기본적으로 보이는 것으로 설정
    LOS_direction = (target_pos - radar_pos) / norm(target_pos - radar_pos); % 단위 벡터
    num_points = ceil(norm(target_pos - radar_pos) / interval); % 샘플링 점 수
    % fprintf("%d\n", num_points);

    for i = 1:num_points
        current_point = radar_pos + i * interval * LOS_direction; % LOS 상의 현재 점
        x = current_point(1);
        y = current_point(2);
        z = current_point(3);

        % 현재 점에 가장 가까운 지형 고도 가져오기
        [~, ix] = min(abs(X(1, :) - x));
        [~, iy] = min(abs(Y(:, 1) - y));
        terrain_alt = Z(iy, ix);

        % 지형 고도가 LOS 벡터의 고도보다 높으면 막힘
        if terrain_alt > z
            is_visible = false;
            return; % 가려짐을 확인한 즉시 반환
        end
    end
end
    
%     is_visible = true; % 기본적으로 보이는 것으로 설정
%     LOS_direction = (target_pos - radar_pos) / norm(target_pos - radar_pos); % 단위 벡터
%     num_points = ceil(norm(target_pos - radar_pos) / interval); % 샘플링 점 수
% 
%     % 시작점과 끝점의 고도
%     start_alt = radar_pos(3);
%     end_alt = target_pos(3);
% 
%     for check_idx = 1:num_points
%         % LOS 벡터 상의 현재 점 계산
%         current_point = radar_pos + check_idx * interval * LOS_direction;
%         x = current_point(1);
%         y = current_point(2);
% 
%         % `threshold_z` 계산 (시작 고도와 끝 고도 사이의 선형 보간)
%         threshold_z = start_alt + (end_alt - start_alt) * check_idx / num_points;
% 
%         % `check_alt` 계산 (지형 데이터에서 현재 점의 고도 추출)
%         check_alt = cal_alt(x, y, X, Y, Z);
% 
%         % 가시성 판단 (지형 고도가 `threshold_z`를 초과하면 막힘)
%         if check_alt > threshold_z
%             is_visible = false;
%             return; % 가려진 경우 즉시 반환
%         end
%     end
% end
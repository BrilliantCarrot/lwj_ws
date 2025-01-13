function is_blocked = check_target_behind(RADAR, PosN, X,Y,Z,interval,LOS_length)
    % PosN: 목표물 위치 [x, y, z]
    % X, Y, Z: 지형 데이터 (각각 x, y, z 좌표 행렬)
    % interval: 샘플링 간격
    % LOS_length: LOS 벡터 길이 (단위: m)
    % 레이더에서 목표물을 보았을 때
    is_blocked = false;
    radar_pos = RADAR.RadarPos(1, :); % 레이더 위치 [x, y, z]
    LOS_direction = (PosN - radar_pos) / norm(PosN - radar_pos); % 단위 LOS 벡터
    num_points = ceil(LOS_length / interval);
    for i = 1:num_points
        current_point = radar_pos + (i * interval) * LOS_direction; % 샘플링된 LOS 점
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
                is_blocked = true; % 가려짐으로 설정
                % fprintf("지형에 의해 가려짐 \n")
                break; % 더 이상 확인하지 않음
            end
            % fprintf("지형에 의해 가려지지 않음 \n")
        end
    end
end


function is_blocked = check_target_behind(RADAR, PosN, X, Y, Z, interval)
    % RADAR: 레이더 정보 구조체
    % PosN: 목표 비행체 위치 [x, y, z]
    % X, Y, Z: 지형 데이터
    % interval: 샘플링 간격

    % 레이더와 목표 간 LOS 벡터 계산
    RelPos = - RADAR.RadarPos(1,:) + PosN;      % 레이더에서 목표로의 상대 위치
    LOS_direction = RelPos / norm(RelPos);      % 단위 벡터로 정규화

    % 목표 비행체의 뒤쪽으로 LOS 벡터를 확장
    LOS_length = 100000;    % 최대 탐색 거리
    num_points = ceil(LOS_length / interval);   % 샘플링 포인트 수
    LOS_points = zeros(num_points, 3);          % 샘플링된 점들 저장
    for i = 1:num_points
        LOS_points(i, :) = PosN + (i * interval) * LOS_direction;
    end

    % 지형지물 확인
    is_blocked = false;
    for i = 1:num_points
        current_point = LOS_points(i, :);       % 현재 샘플링된 점 [x, y, z]
        x = current_point(1);
        y = current_point(2);
        z = current_point(3);

        % 해당 위치의 지형 고도 계산
        terrain_alt = cal_alt(x, y, X, Y, Z);

        % 지형 고도가 샘플링된 LOS 점보다 높으면 시야가 막힌 것으로 판단
        if terrain_alt > z
            is_blocked = true;
            break; % 더 이상 확인할 필요 없음
        end
    end
end
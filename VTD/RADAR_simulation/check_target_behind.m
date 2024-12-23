function is_behind_blocked = check_target_behind(RADAR, PosN, X, Y, Z)
    % RADAR: 레이더 정보 구조체
    % PosN: 목표물 위치 [x, y, z]
    % X, Y, Z: 지형 데이터 매트릭스
    % 반환값: is_behind_blocked (true = 뒤에 지형 있음, false = 뒤에 하늘)

    % 레이더 위치
    x_r = RADAR.RadarPos(1, 1);
    y_r = RADAR.RadarPos(1, 2);
    z_r = RADAR.RadarPos(1, 3);

    % 목표물 위치
    x_t = PosN(1);
    y_t = PosN(2);
    z_t = PosN(3);

    % 레이더 -> 목표물 벡터 (시선 방향)
    dir_vector = [x_t - x_r, y_t - y_r, z_t - z_r];
    dir_vector = dir_vector / norm(dir_vector); % 단위 벡터화

    % 뒤쪽 방향으로의 확장
    back_vector = -dir_vector; % 반대 방향 벡터
    n_points = 50; % 샘플링 점 개수
    step_size = 500; % 샘플링 간격 (예: 500m)

    % 뒤쪽으로 샘플링된 좌표 생성
    back_x = x_t + (1:n_points) * step_size * back_vector(1);
    back_y = y_t + (1:n_points) * step_size * back_vector(2);
    back_z = z_t + (1:n_points) * step_size * back_vector(3);

    % 뒤쪽 지형 확인
    is_behind_blocked = false; % 초기값: 막히지 않음
    for i = 1:n_points
        % 현재 샘플링 지점의 고도 계산
        terrain_alt = cal_alt(back_x(i), back_y(i), X, Y, Z);

        % 샘플링 지점에서 고도가 존재하면 막혀 있다고 판단
        if terrain_alt > back_z(i)
            is_behind_blocked = true;
            break;
        end
    end
end


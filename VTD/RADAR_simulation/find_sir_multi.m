function sir = find_sir_multi(radars, target_pos, RADAR)
    % radars: 복수의 레이더 위치 (Nx3 행렬, 각 행이 레이더 위치)
    % target_pos: 목표물 위치 [x, y, z]
    % RADAR: 레이더 구조체
    num_radars = size(radars, 1);
    sir_values = zeros(num_radars, 1);
    for i = 1:num_radars
        radar_pos = radars(i, :);
        sir_values(i) = find_sir(radar_pos, target_pos, RADAR);
    end
    sir = max(sir_values);
end
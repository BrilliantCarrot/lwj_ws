function sir = find_sir_multi(radars, target_pos, RADAR, X, Y, Z, interval)
    % 복수의 레이더에 대한 SIR을 계산
    % radars: 복수의 레이더 위치 (Nx3 행렬, 각 행이 레이더 위치)
    % target_pos: 목표점 위치 [x, y, z]
    % RADAR: 레이더 구조체

    num_radars = size(radars, 1);
    sir_values = -inf(num_radars, 1); % 기본값 -infinity로 초기화
    for i = 1:num_radars
        radar_pos = radars(i, :);
        % 가시성 검사
        if check_visibility(radar_pos, target_pos, X, Y, Z, interval)
            % 가시성이 확보된 경우에만 SIR 계산
            sir_values(i) = find_sir(radar_pos, target_pos, RADAR);
        else
            sir_values(i) = -100; % 지형에 의해 안보이게 되면 낮은 SIR 값 설정
        end
    end
    % 최대 SIR 값 반환
    sir = max(sir_values);
end

%     num_radars = size(radars, 1);
%     sir_values = zeros(num_radars, 1);
%     for i = 1:num_radars
%         radar_pos = radars(i, :);
%         sir_values(i) = find_sir(radar_pos, target_pos, RADAR);
%     end
%     sir = max(sir_values);
% end
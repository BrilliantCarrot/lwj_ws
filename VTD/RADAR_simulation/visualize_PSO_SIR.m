function visualize_PSO_SIR_enhanced(optimal_path, sir_data, radar_pos, X, Y, Z)
    % optimal_path: PSO 알고리즘 결과로 생성된 최적 경로
    % sir_data: PSO 알고리즘에서 각 단계별로 계산된 SIR 분포 데이터
    % radar_pos: 레이더 위치
    % X, Y, Z: 지형 데이터

    % SIR 로그 스케일 변환
    sir_data_log = cellfun(@(x) log10(max(x, 1e-3)), sir_data, 'UniformOutput', false); % 최소값 제한

    % 기본 시각화 설정
    figure;
    set(gcf, 'Position', [200, 100, 1000, 750]);
    hold on;

    % 지형 시각화
    s = surf(X / 1000, Y / 1000, Z, sir_data_log{1}, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    colormap(jet);
    colorbar;
    caxis([log10(1e-3), log10(20)]); % 강조 범위 설정
    xlabel('X [km]');
    ylabel('Y [km]');
    zlabel('Altitude [m]');
    title('Optimized Path and Enhanced SIR Distribution');
    view(-20, 80);
    grid on;

    % 레이더 위치 표시
    plot3(radar_pos(1) / 1000, radar_pos(2) / 1000, radar_pos(3), ...
          'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');

    % 초기 경로와 반경 초기화
    path_plot = plot3(optimal_path(1, 1) / 1000, optimal_path(1, 2) / 1000, optimal_path(1, 3), ...
                      'r-', 'LineWidth', 2);
    radius_plot = plot3([], [], [], 'c--', 'LineWidth', 1);

    % 업데이트 주기 설정
    pause_time = 1; % 1초 간격으로 업데이트

    % 시각화 업데이트
    for t = 1:length(optimal_path)
        % 현재 궤적 업데이트
        set(path_plot, 'XData', optimal_path(1:t, 1) / 1000, ...
                       'YData', optimal_path(1:t, 2) / 1000, ...
                       'ZData', optimal_path(1:t, 3));

        % 현재 SIR 분포 업데이트 (로그 스케일 적용)
        sir_matrix_log = sir_data_log{t};
        set(s, 'CData', sir_matrix_log);

        % 현재 위치에서의 SIR 반경 표시
        current_pos = optimal_path(t, :);
        search_radius = 500; % 탐색 반경 (반경이 동적으로 변할 경우 업데이트 가능)
        [circle_x, circle_y] = generate_circle(current_pos(1), current_pos(2), search_radius, X, Y);
        set(radius_plot, 'XData', circle_x / 1000, 'YData', circle_y / 1000, 'ZData', ones(size(circle_x)) * current_pos(3));

        % 시각화 업데이트
        drawnow;
        pause(pause_time);
    end

    legend('Terrain', 'Radar Position', 'Optimized Path', 'Search Radius', 'Location', 'Best');
end

% 탐색 반경을 나타내는 원 생성 함수
function [circle_x, circle_y] = generate_circle(center_x, center_y, radius, X, Y)
    theta = linspace(0, 2 * pi, 100);
    circle_x = center_x + radius * cos(theta);
    circle_y = center_y + radius * sin(theta);

    % X, Y 범위 안에서만 원이 생성되도록 제한
    circle_x = max(min(circle_x, max(X(:))), min(X(:)));
    circle_y = max(min(circle_y, max(Y(:))), min(Y(:)));
end
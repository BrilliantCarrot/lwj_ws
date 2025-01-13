function optimal_path = PSO_SIR_Optimization(radar_pos, X, Y, Z, RADAR)
    % PSO 파라미터 정의
    num_particles = 1000;    
    max_iter = 100;        
    w = 0.7;               
    c1 = 1.5;              
    c2 = 1.5;              

    % 탐색 공간 정의
    x_min = min(X(:)); x_max = max(X(:));
    y_min = min(Y(:)); y_max = max(Y(:));
    % z_min = min(Z(:)); z_max = max(Z(:));

    % 입자의 위치와 속도 초기화
    % 입자 위치의 경우 DTED 상에서 랜덤 위치이며 고도의 경우 DTED z축 고도 + 100
    particles = [rand(num_particles, 1) * (x_max - x_min) + x_min, ...
                 rand(num_particles, 1) * (y_max - y_min) + y_min, ...
                 zeros(num_particles, 1)];
    for i = 1:num_particles
        % x,y 지점에서 고도+100의 z값을 구함
        %%%%%%%%%% 아마 그냥 x,y,지점의 고도 z값 + 100만 하면 될지도 %%%%%%%%%%
        x = particles(i, 1);
        y = particles(i, 2);
        z = calculate_Z(x, y, X, Y, Z) + 100;
        particles(i, 3) = z;
    end
    velocities = zeros(size(particles));    % 속도는 0으로 초기화

    pbest = particles;
    % particles(i, :): i번째 입자의 초기 위치이며 입자의 3D 좌표 [x, y, z]를 포함
    % 레이더의 위치는 고정(추후 여러개 레이더라면 바꿔야 될 수도있음)
    % 타겟의 위치는 지형 셀 전체
    pbest_scores = arrayfun(@(i) find_sir(radar_pos, particles(i,:), RADAR), 1:num_particles)';
    % pbest_scores는 각 입자의 초기 SIR 값을 저장한 열 벡터로 크기는 [num_particles, 1]
    % pbest_scores에서 최소값(gbest_score)과 해당 최소값이 위치한 인덱스(gbest_idx)를 반환
    % gbest가 초기 SIR 값 중 가장 작은 값으로 현재까지의 최적 SIR 값
    [gbest_score, gbest_idx] = min(pbest_scores);
    % pbest 배열에서 gbest_idx 위치에 있는 입자의 좌표를 가져옴
    gbest = pbest(gbest_idx, :);

    % PSO 메인 반복문
    % 반복문에서 SIR을 계산하며 pbest 및 gbest 업데이트
    for iter = 1:max_iter
        for i = 1:num_particles
            % Calculate SIR for current particle
            current_score = find_sir(radar_pos, particles(i,:), RADAR);
            % 현재 입자 SIR이 개인 최적 위치 SIR보다 낮은 경우 업데이트
            if current_score < pbest_scores(i)
                pbest_scores(i) = current_score;
                pbest(i, :) = particles(i, :);
            end
            % 현재 입자 SIR이 전역 최적 위치 SIR보다 낮은 경우 gbest로 설정
            if current_score < gbest_score
                gbest_score = current_score;
                gbest = particles(i, :);
            end
        end
        % 속도 및 위치 업데이트
        for i = 1:num_particles
            r1 = rand();
            r2 = rand();
            % pbest(i, :) - particles(i, :): 입자 현재 위치와 개인 최적 위치 사이의 벡터
            % 개인 최적 위치로 이동하려는 방향을 제공
            % gbest - particles(i, :): 입자 현재 위치와 전역 최적 위치 사이으 벡터
            % 전역 최적 위치로 이동하려는 방향을 제공
            % 속도 업데이트
            velocities(i, :) = w * velocities(i, :) + ...
                               c1 * r1 * (pbest(i, :) - particles(i, :)) + ...
                               c2 * r2 * (gbest - particles(i, :));
            % 위치 업데이트
            particles(i, :) = particles(i, :) + velocities(i, :);
            particles(i, 1) = max(min(particles(i, 1), x_max), x_min);
            particles(i, 2) = max(min(particles(i, 2), y_max), y_min);
            particles(i, 3) = calculate_Z(particles(i, 1), particles(i, 2), X, Y, Z) + 100;
        end
        fprintf('Iteration %d/%d, Best SIR: %.2f dB\n', iter, max_iter, gbest_score);
    end
    % 최적 경로 결과
    optimal_path = gbest;
end

% x,y 좌표에서 맞는 고도 z값을 산출
function z = calculate_Z(x, y, X, Y, Z)
    [~, ix] = min(abs(X(1, :) - x));
    [~, iy] = min(abs(Y(:, 1) - y));
    z = Z(iy, ix);
end

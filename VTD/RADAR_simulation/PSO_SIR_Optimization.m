function optimal_path = PSO_SIR_Optimization(radar_pos, X, Y, Z, RADAR)
    % PSO Parameters
    num_particles = 50;    % Number of particles
    max_iter = 100;        % Maximum number of iterations
    w = 0.7;               % Inertia weight
    c1 = 1.5;              % Cognitive coefficient
    c2 = 1.5;              % Social coefficient

    % 탐색 공간
    x_min = min(X(:)); x_max = max(X(:));
    y_min = min(Y(:)); y_max = max(Y(:));
    z_min = min(Z(:)); z_max = max(Z(:));

    % Initialize particles and velocities
    particles = [rand(num_particles, 1) * (x_max - x_min) + x_min, ...
                 rand(num_particles, 1) * (y_max - y_min) + y_min, ...
                 rand(num_particles, 1) * (z_max - z_min) + z_min];
    velocities = zeros(size(particles));

    % Initialize personal and global bests
    pbest = particles;
    pbest_scores = arrayfun(@(i) calculate_SIR(radar_pos, particles(i, :), X, Y, Z, RADAR), 1:num_particles)';
    [gbest_score, gbest_idx] = min(pbest_scores);
    gbest = pbest(gbest_idx, :);

    % PSO main loop
    for iter = 1:max_iter
        for i = 1:num_particles
            % Calculate SIR for current particle
            current_score = calculate_SIR(radar_pos, particles(i, :), X, Y, Z, RADAR);

            % Update personal best if necessary
            if current_score < pbest_scores(i)
                pbest_scores(i) = current_score;
                pbest(i, :) = particles(i, :);
            end

            % Update global best if necessary
            if current_score < gbest_score
                gbest_score = current_score;
                gbest = particles(i, :);
            end
        end

        % Update velocities and positions
        for i = 1:num_particles
            r1 = rand();
            r2 = rand();
            velocities(i, :) = w * velocities(i, :) + ...
                               c1 * r1 * (pbest(i, :) - particles(i, :)) + ...
                               c2 * r2 * (gbest - particles(i, :));
            particles(i, :) = particles(i, :) + velocities(i, :);

            % Enforce boundary conditions
            particles(i, :) = max(particles(i, :), [x_min, y_min, z_min]);
            particles(i, :) = min(particles(i, :), [x_max, y_max, z_max]);
        end

        % Display progress
        fprintf('Iteration %d/%d, Best SIR: %.2f dB\n', iter, max_iter, gbest_score);
    end

    % Output optimal path
    optimal_path = gbest;
end

function SIR = calculate_SIR(radar_pos, target_pos, X, Y, Z, RADAR)
    % SIR calculation for a given target position
    [sig1, ~, ~, ~, ~, ~, SIR_dB, ~] = RADAR_Module_SIR(false, RADAR, target_pos, 1, X, Y, Z);
    SIR = SIR_dB;
end

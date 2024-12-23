function [sig,sigma_MBc, sigma_SLc,sigma_clutter,SNR,SCR] = RADAR_Module_copy(RADAR,PosN,lambda_num,X,Y,Z)

% 10dBsm = 10m²,  x dBsm =(10^(x/10))m^2
% SNR : Signal to Noise Ratio is standard measure of a radar's ability to
% detect a given target at range from radar
% SNR = (P_t[W] * G^2 * lambda^2[m^2] * RCS[m^2]) / (4pi^2 * R^4[m^4] * N(=k * T_s * B_n)[W] * L)
% Using Matlab radar toolbox
% Reference Radar : S-band(RL-2000/GCI), X-band(Scanter 4000)

    
    
    % for lambda num = 1, 2GHz
    if lambda_num == 1
        rcs_table = RADAR.RCS1;
        pitch_array = RADAR.theta(1,:) * pi/180;
        yaw_array = RADAR.psi(:,1) * pi/180;
        % sig = 0;
        lambda = freq2wavelen(2*10^9);          % [m] wavelength
        Pt = 14000;                             % [W] peak power
        tau = 0.00009;                          % [s] pulse width
        G = 34;                                 % [dBi] antenna gain
        Ts = 290;                               % [K] System temp 
        L = 8.17;                                  % [dB] Loss
        prf = 1000;                             % [Hz] Pulse repetition frequency 
    % for lambda num = 2, 8GHz
        elseif lambda_num == 2
        rcs_table = RADAR.RCS2;
        pitch_array = RADAR.theta(1,:) * pi/180;
        yaw_array = RADAR.psi(:,1) * pi/180;
        % sig = 0;
        lambda = freq2wavelen(8*10^9);          % [m] wavelength
        Pt = 6000;                              % [W] peak power
        tau = 0.0001;                           % [s] pulse width
        G = 39;                                 % [dBi] antenna gain
        Ts = 290;                               % [K] System temp 
        L = 0;                                  % [dB] Loss
        prf = 2200;                             % [Hz] Pulse repetition frequency 
    
    end
    
    % 위치 계산
    % for i = 1:RADAR.N_Radar
    RelPos = - RADAR.RadarPos(lambda_num,:) + PosN;
    Range = norm(RelPos);   % 레이더와 기체 간 거리(Slant Range)
    los_pitch = atan2(-RelPos(3),norm(RelPos(1:2)));
    los_yaw = atan2(RelPos(2),RelPos(1));

    % 지표면 고도
    % radar_surface_alt = cal_alt(RADAR.RadarPos(lambda_num,1), RADAR.RadarPos(lambda_num,2), X, Y, Z);
    % radar_height_above_surface = RADAR.RadarPos(lambda_num,3) - radar_surface_alt;
    % 
    % target_surface_alt = cal_alt(PosN(1), PosN(2), X, Y, Z);
    % height_above_surface = PosN(3) - target_surface_alt;

    % RCS 계산
    % los_yaw: LOS 벡터의 방위각
    % p_idx: RCS 테이블에서 고각(pitch)에 해당하는 데이터를 참조하기 위한 인덱스 값,
    % pitch는 목표물과 레이더 간 실제 고각

    pitch = Angle_trim(los_pitch);  
    yaw = Angle_trim(los_yaw);
    p_idx = Find_Index(pitch_array,length(pitch_array),pitch);
    y_idx = Find_Index(yaw_array,length(yaw_array),yaw);
    p_lower = rcs_table(:,p_idx);
    p_upper = rcs_table(:,p_idx+1);
    p_rcs = p_lower + (pitch-pitch_array(p_idx))*(p_upper-p_lower)/(pitch_array(p_idx+1)-(pitch_array(p_idx)));
    y_lower = p_rcs(y_idx,:);
    y_upper = p_rcs(y_idx+1,:);
    rcs = y_lower + (yaw-yaw_array(y_idx))*(y_upper-y_lower)/(yaw_array(y_idx+1)-(yaw_array(y_idx)));   % dB
    %             rcs_min = min(min(rcs_table));
    
    rcs =   10^(rcs/10);    % log 스케일 rcs
    Du = tau * prf;
    Fecl = eclipsingfactor(Range, Du, prf);

    % dB 기준 SNR
    SNR = radareqsnr(lambda,Range,Pt,tau,'Gain',G,'Ts',Ts,'RCS',rcs,'CustomFactor',Fecl,'Loss',L);
    sig = SNR;



    %%%%%%

    % 메인빔 및 사이드로브 클러터 계산
    % theta_E = deg2rad(2);               % Elevation Beamwidth
    % theta_A = deg2rad(1);               % Azimuth Beamwidth
    % sigma_0 = 10^(-20 / 10);            % Surface Clutter Coefficient (-20 dB)
    % SL_rms = 10^(-20 / 10);             % Side Lobe RMS Level
    % 
    % delta_R = Range * lambda / 2;       % Slant Range Resolution
    % delta_Rg = delta_R * cos(los_pitch);% Ground Range Resolution
    % 
    % G_theta = exp(-2.776 * (los_pitch / theta_E)^2); % Gaussian Antenna Gain
    % 
    % A_MBc = delta_Rg * Range * theta_A; % Main Beam Clutter Area
    % A_SLc = delta_Rg * pi * Range;      % Side Lobe Clutter Area
    % 
    % sigma_MBc = sigma_0 * A_MBc * G_theta^2;
    % sigma_SLc = sigma_0 * A_SLc * SL_rms^2;
    % 
    % sigma_clutter = sigma_MBc + sigma_SLc; % Total Clutter RCS
    % 
    % % SNR 및 SIR 계산
    % k = 1.38e-23;     % Boltzmann Constant
    % B = 1e6;          % Bandwidth
    % F = 10^(6 / 10);  % Noise Figure
    % 
    % SNR = (Pt * 10^(G / 10)^2 * rcs * lambda^2) / ...
    %       ((4 * pi)^3 * Range^4 * k * Ts * B * F * L);
    % 
    % SCR = (Pt * 10^(G / 10)^2 * rcs * lambda^2) / ...
    %       (Pt * 10^(G / 10)^2 * sigma_clutter * lambda^2);
    % 
    % SIR = 1 / ((1 / SNR) + (1 / SCR));  % SIR (Signal-to-Interference Ratio)
    % sig = 10 * log10(SIR);              % Convert to dB
    % sigma_MBc = sigma_MBc;              % 메인 빔 클러터 RCS
    % sigma_SLc = sigma_SLc;              % 사이드 로브 클러터 RCS
    % sigma_clutter = sigma_clutter;      % 총 클러터 RCS

    
    % if is_behind_blocked
        % 기체 뒤 배경이 비어있으면 SNR 값을 sig로 쓰도록 계산
        % sig = sig;

    % else
        % 기체 뒤 배경이 존재하면 지표면 클러터를 적용한 SIR 값을 sig로 쓰도록 계산
        % 클러터 적용 SIR 계산에 필요한 추가 파라미터

        % c = 3e8;                      % 전파 속도 (m/s)
        % sigma_0 = 10^(-20/10);        % 클러터 산란(반사)계수 (선형(log) 스케일), -20 dB(Flatland)
        % theta_A = deg2rad(1);         % 방위각 빔폭 (rad)
        % theta_E = deg2rad(2);         % 고각 빔폭 (rad)
        % SL_rms = 10^(-20/10);         % 사이드로브의 RMS 수준 (선형(log) 스케일), -20 dBc = 3e8;
        % 
        % h_r = RADAR.RadarPos(1, 3);   % RADAR.RadarPos의 세 번째 요소가 레이더 고도
        % h_t = PosN(3);                % PosN의 세 번째 요소가 목표물의 고도
        % 
        % R_e = 6.371e6;                % 지구 반지름 (m)
        % theta_r = asin(min(1, max(-1, h_r ./ Range)));          % 지표에서 레이더 높이까지의 각도
        % theta_e = asin(min(1, max(-1, (h_t - h_r) ./ Range)));  % 레이더 높이에서 기체까지의 각도
        % Rg = Range .* cos(theta_r);                             % Slant Range의 지표 투영
        % delta_R = c * tau / 2;                                  % Slant Range의 거리 해상도
        % delta_Rg = delta_R * cos(theta_r);                      % 지표면 투영 거리 해상도
        % theta_sum = theta_e + theta_r;                      
        % G_theta = exp(-2.776 * (theta_sum ./ theta_E).^2);  % 고각 및 방위각 두개에 대한 안테나 이득
        % % 메인빔 클러터 면적 및 RCS 계산
        % A_MBc = delta_Rg .* Rg * theta_A;
        % sigma_MBc = sigma_0 .* A_MBc .* G_theta.^2;
        % % 사이드로브 클러터 면적 및 RCS 계산
        % A_SLc = delta_Rg .* pi .* Rg;
        % sigma_SLc = sigma_0 .* A_SLc .* SL_rms.^2;
        % % 레이다 탐지 범위의 성분 중 지평선 축의 거리
        % R_h = sqrt((8 * R_e * h_r)/3);
        % 
        % % 클러터 RCS 계산
        % sigma_TOTc = (sigma_MBc + sigma_SLc) ./ (1 + (Range / R_h).^4);
        % sigma_clutter = sigma_TOTc;        % 지형 클러터의 RCS (m^2)
        % 
        % % SCR 및 SIR 계산
        % % SCR = (Pt * G^2 * rcs * lambda^2) ./ (Pt * G^2 * sigma_clutter * lambda^2);
        % SCR = rcs./sigma_clutter;
        % SIR = 1./((1./SNR)+(1./SCR));       % 클러터의 영향이 고려된 목표물의 SNR 값을 SIR(SCNR)로 정의
        % SIR_dB = 10 * log10(SIR);           % dB로 표현된 최종 SIR 값을 출력
        % sig = SIR_dB;
    
        % 기체 뒤 배경이 존재하면 지표면 클러터를 적용한 SIR 값을 sig로 쓰도록 계산
        % 클러터 적용 SIR 계산에 필요한 추가 파라미터
        % c = 3e8;                      % 전파 속도 (m/s)
        % sigma_0 = 10^(-20/10);        % 클러터 산란(반사)계수 (선형(log) 스케일), -20 dB(Flatland)
        % theta_A = deg2rad(1);         % 방위각 빔폭 (rad)
        % theta_E = deg2rad(2);         % 고각 빔폭 (rad)
        % SL_rms = 10^(-20/10);         % 사이드로브의 RMS 수준 (선형(log) 스케일), -20 dBc = 3e8;
        % h_r = RADAR.RadarPos(1, 3);   % RADAR.RadarPos의 세 번째 요소가 레이더 고도
        % h_t = PosN(3);                % PosN의 세 번째 요소가 목표물의 고도
        % R_e = 6.371e6;                % 지구 반지름 (m)
        % theta_r = asin(min(1, max(-1, h_r ./ Range)));          % 지표에서 레이더 높이까지의 각도
        % theta_e = asin(min(1, max(-1, (h_t - h_r) ./ Range)));  % 레이더 높이에서 기체까지의 각도
        % Rg = Range .* cos(theta_r);                             % Slant Range의 지표 투영
        % R_h = sqrt((8 * R_e * h_r)/3);                          % 레이다 탐지 범위의 성분 중 지평선 축의 거리
        % propag_atten = (1 + (Range / R_h).^4);                  % propagation attenuation due to round earth
        % delta_R = c * tau / 2;                                  % Slant Range의 거리 해상도
        % delta_Rg = delta_R * cos(theta_r);                      % 지표면 투영 거리 해상도
        % theta_sum = theta_e + theta_r;                      
        % G_theta = exp(-2.776 * (theta_sum ./ theta_E).^2);  % 고각 및 방위각 두개에 대한 안테나 이득
        % sigma_clutter = (sigma_0 .* Rg .* delta_Rg) .* (pi * SL_rms * SL_rms + theta_A .* G_theta.^2) ./ propag_atten;
        % sigma_clutter = 10 * log10(sigma_clutter);    
        % % SCR 및 SIR 계산
        % SCR = (Pt * G^2 * rcs * lambda^2) ./ (Pt * G^2 * sigma_clutter * lambda^2);
        % SIR = 1./((1./SNR)+(1./SCR));       % 클러터의 영향이 고려된 목표물의 SNR 값을 SIR(SCNR)로 정의
        % SIR_dB = 10 * log10(SIR);           % dB로 표현된 최종 SIR 값을 출력
        % sig = SIR_dB;

    % end    

end


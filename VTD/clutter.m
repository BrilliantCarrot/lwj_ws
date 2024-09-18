clear;
clc;
close all;

%% constantGammaClutter에 대한 매트랩 예시

%% --------------------Simulate Clutter for System with Known Power--------------------

% Simulate the clutter return from terrain with a gamma value of 0 dB. 
% The effective transmitted power of the radar system is 5 kW.

% Set up the characteristics of the radar system. This system uses a four-element uniform linear array (ULA). 
% The sample rate is 1 MHz, and the PRF is 10 kHz. The propagation speed is the speed of light, 
% and the operating frequency is 300 MHz. 
% The radar platform is flying 1 km above the ground with a path parallel to the ground along the array axis. 
% The platform speed is 2 km/s. The mainlobe has a depression angle of 30°.

% S-Band 레이더의 경우 파라미터 설정
% Sensor를 설정하기위하여 array = phased.ULA
% prf = 3.0e3 X -> 1.0e3
% height 레이더 설치 위치, 30
% direction은 플랫폼 이동 방향으로 정지되어있는 경우 플랫폼 이동 속도를 0으로 설정하여 이 값을 무시하도록 설정
% speed = 0
% c = physconst('Lightspeed');
% fc = 3e9
% fs = 20e6
% lambda = c/fc;
% tergamma는 surfacegamma 함수 파라미터로 'wooded hill' 선정하여 결과 이용, wooded hill의 경우 -10
% tpower는 peak power 또는 transmit power와 antenna gain의 곱으로 표현, 1500 x 34 = 51e3 

% X-Band 레이더의 경우 파라미터 설정
% Sensor를 설정하기위하여 array = phased.ULA
% prf = 2.2e3
% height 레이더 설치 위치, 30
% direction은 플랫폼 이동 방향으로 정지되어있는 경우 플랫폼 이동 속도를 0으로 설정하여 이 값을 무시하도록 설정
% speed = 0
% c = physconst('Lightspeed');
% fc = 9e9
% fs = 20e6
% lambda = c/fc;
% tergamma = 'wooded hill'
% tpower = 6000 x 39 = 234,000 = 234e6

clear;
clc;
close all;

Nele = 4;
c = physconst('Lightspeed');
fc = 300.0e6;
lambda = c/fc;
array = phased.ULA('NumElements',Nele,'ElementSpacing',lambda/2);
fs = 1.0e6;
prf = 10.0e3;               % 펄스 반복 주파수
height = 1000.0;            % 항공 레이더
direction = [90;0];
speed = 2.0e3;
depang = 30.0;
mountingAng = [depang,0,0];

% Create the clutter simulation object. The configuration assumes the earth is flat.
% The maximum clutter range of interest is 5 km, and the maximum azimuth coverage is ±60°.

Rmax = 5000.0;          % 클러터가 발생할 최대 거리
Azcov = 120.0;          % 클러터 발생 방위각 범위
tergamma = 0.0;         % 클러터 반사 강도의 감마 계수
tpower = 5000.0;        % 레이더 송신 전력
clutter_1 = constantGammaClutter('Sensor',array,...
    'PropagationSpeed',c,'OperatingFrequency',fc,'PRF',prf,...
    'SampleRate',fs,'Gamma',tergamma,'EarthModel','Flat',...
    'TransmitERP',tpower,'PlatformHeight',height,...
    'PlatformSpeed',speed,'PlatformDirection',direction,...
    'MountingAngles',mountingAng,'ClutterMaxRange',Rmax,...
    'ClutterAzimuthSpan',Azcov,'SeedSource','Property',...
    'Seed',40547);

% Simulate the clutter return for 10 pulses.

Nsamp = fs/prf;
Npulse = 10;
sig = zeros(Nsamp,Nele,Npulse);         % 100개의 행, 4개의 열, 10개의 차원으로 된 데이터 신호 데이터 생성
for m = 1:Npulse    % 각 펄스에 대해 클러터 신호를 생성
    sig(:,:,m) = clutter_1();
end

% Plot the angle-Doppler response of the clutter at the 20th range bin.

response = phased.AngleDopplerResponse('SensorArray',array,...
    'OperatingFrequency',fc,'PropagationSpeed',c,'PRF',prf);
plotResponse(response,shiftdim(sig(20,:,:)),'NormalizeDoppler',true)

surfclutterrcs

%% Range-Doppler 에서 시각화

% Reshape the signal matrix to match the required format
sig2D = reshape(sig, Nsamp, Nele * Npulse);

% Create the Range-Doppler response object without PRF
response = phased.RangeDopplerResponse('RangeMethod', 'FFT', 'DopplerOutput', 'Frequency', 'SampleRate', fs);

% Compute and plot the Range-Doppler map
plotResponse(response, sig2D);

%% --------------------Simulate Clutter Using Known Transmit Signal--------------------

% Simulate the clutter return from terrain with a gamma value of 0 dB. 
% You input the transmit signal of the radar system when creating clutter. 
% In this case, you do not use the TransmitERP property.

% Set up the characteristics of the radar system. This system has a 4-element uniform linear array (ULA). 
% The sample rate is 1 MHz, and the PRF is 10 kHz. The propagation speed is the speed of light,
% and the operating frequency is 300 MHz. The radar platform is flying 1 km above the ground with a path parallel to the ground 
% along the array axis. The platform speed is 2 km/s. The mainlobe has a depression angle of 30°.

Nele = 4;
c = physconst('Lightspeed');
fc = 300.0e6;
lambda = c/fc;
ula = phased.ULA('NumElements',Nele,'ElementSpacing',lambda/2);
fs = 1.0e6;
prf = 10.0e3;
height = 1.0e3;
direction = [90;0];
speed = 2.0e3;
depang = 30;
mountingAng = [depang,0,0];

% Create the clutter simulation object and configure it to accept an transmit signal as an input argument. 
% The configuration assumes the earth is flat. The maximum clutter range of interest is 5 km, 
% and the maximum azimuth coverage is ±60°.

Rmax = 5000.0;
Azcov = 120.0;
tergamma = 0.0;
clutter_2 = constantGammaClutter('Sensor',ula,...
    'PropagationSpeed',c,'OperatingFrequency',fc,'PRF',prf,...
    'SampleRate',fs,'Gamma',tergamma,'EarthModel','Flat',...
    'TransmitSignalInputPort',true,'PlatformHeight',height,...
    'PlatformSpeed',speed,'PlatformDirection',direction,...
    'MountingAngles',mountingAng,'ClutterMaxRange',Rmax,...
    'ClutterAzimuthSpan',Azcov,'SeedSource','Property',...
    'Seed',40547);

% Simulate the clutter return for 10 pulses. At each step, pass the transmit signal as an input argument. 
% The software computes the effective transmitted power of the signal. The transmit signal is a 
% rectangular waveform with a pulse width of 2 μs.

tpower = 5.0e3;
pw = 2.0e-6;
X = tpower*ones(floor(pw*fs),1);
Nsamp = fs/prf;
Npulse = 10;
sig = zeros(Nsamp,Nele,Npulse);
for m = 1:Npulse
    sig(:,:,m) = step(clutter_2,X);
end

% Plot the angle-Doppler response of the clutter at the 20th range bin.

response = phased.AngleDopplerResponse('SensorArray',ula,...
    'OperatingFrequency',fc,'PropagationSpeed',c,'PRF',prf);
plotResponse(response,shiftdim(sig(20,:,:)),'NormalizeDoppler',true)


%% 매트랩 웹 페이지 제공 클러터 생성 튜토리얼

% surfaceReflectivityLand를 통한 Constant Gamma Clutter 구현 예시

% Introduction to Radar Scenario Clutter Simulation

% This example shows how to generate monostatic surface clutter signals and detections in a radar scenario. 
% Clutter detections will be generated with a monostatic radarDataGenerator, and clutter return signals will be generated 
% with a radarTransceiver, using both homogenous surfaces and real terrain data from a DTED file. 
% theaterPlot is used to visualize the scenario surface and clutter generation.

% Configure Scenario for Clutter Generation
% Configuration of a radar scenario to simulate surface clutter involves creating a radarScenario object, 
% adding platforms with mounted radars, adding surface objects that define the physical properties of the scenario surface, 
% and enabling clutter generation for a specific radar in the scene.
% Select a Radar Model

clear;
clc;
close all;

mountAng = [-90 10 0];
fc = 5e9;
rngRes = 150;
prf = 12e3;
numPulses = 64;

% The radarDataGenerator is a statistical model that does not directly emulate an antenna pattern. Instead, 
% it has properties that define the field of view and angular resolution. Use 10 degrees for the field of view and 
% angular resolution in each direction. This configuration is comparable to simulating a single mainlobe with no angle estimation.

fov = [10 10];
angRes = fov;

c = physconst('lightspeed');
lambda = freq2wavelen(fc);
rangeRateRes = lambda/2*prf/numPulses;
unambRange = time2range(1/prf);
unambRadialSpd = dop2speed(prf/4,lambda);
cpiTime = numPulses/prf;
rdr = radarDataGenerator(1,'No scanning','UpdateRate',1/cpiTime,'MountingAngles',mountAng,...
    'DetectionCoordinates','Scenario','HasINS',true,'HasElevation',true,'HasFalseAlarms',false, ...
    'HasRangeRate',true,'HasRangeAmbiguities',true,'HasRangeRateAmbiguities',true, ...
    'MaxUnambiguousRadialSpeed',unambRadialSpd,'MaxUnambiguousRange',unambRange,'CenterFrequency',fc, ...
    'FieldOfView',fov,'AzimuthResolution',angRes(1),'ElevationResolution',angRes(2), ...
    'RangeResolution',rngRes,'RangeRateResolution',rangeRateRes);

% Create a Scenario

scenario = radarScenario('UpdateRate',0,'IsEarthCentered',false);

% 레이더에 대해 초기화

rdrAlt = 1.5e3;
rdrSpd = 70;
rdrDiveAng = 10;
rdrPos = [0 0 rdrAlt];
rdrVel = rdrSpd*[0 cosd(rdrDiveAng) -sind(rdrDiveAng)];
rdrOrient = rotz(90).';
rdrTraj = kinematicTrajectory('Position',rdrPos,'Velocity',rdrVel,'Orientation',rdrOrient);
rdrplat = platform(scenario,'Sensors',rdr,'Trajectory',rdrTraj);

% Define the Scenario Surface

% Create a simple unbounded land surface with a constant-gamma reflectivity model. Use the surfaceReflectivityLand function 
% to create a reflectivity model and attach the reflectivity model to the surface with the RadarReflectivity parameter. 
% Use a gamma value of -20 dB.

% gamma값에 대해 일정한 값 사용

refl = surfaceReflectivityLand('Model','ConstantGamma','Gamma',-20);
srf = landSurface(scenario,'RadarReflectivity',refl);

srf.Boundary

scenario.SurfaceManager

% Enable Clutter Generation
% Clutter Generator

clutRes = rngRes/2;
clutRngLimit = 12e3;
clut = clutterGenerator(scenario,rdr,'Resolution',clutRes,'UseBeam',true,'RangeLimit',clutRngLimit);

% The radarDataGenerator is a statistics-based detectability simulator, and only simulates 
% mainlobe detections within the field of view. As such, having UseBeam of the ClutterGenerator set to true is 
% sufficient to completely capture the effect of clutter interference on the detectability of target platforms 
% when using a radarDataGenerator.

%% Visualize and Run Scenario
% Theater Plotter
% The theaterPlot object can be used along with a variety of theater plotters to create customizable visual representations 
% of the scenario. Start by creating the theater plot.

tp = theaterPlot;

% Now create plotter objects for the scenario surface, clutter regions, and resulting radar detections. 
% The values specified for the DisplayName properties are used for the legend entries.

surfPlotter = surfacePlotter(tp,'DisplayName','Scenario Surface');
clutPlotter = clutterRegionPlotter(tp,'DisplayName','Clutter Region');
detPlotter = detectionPlotter(tp,'DisplayName','Radar Detections','Marker','.','MarkerEdgeColor','magenta','MarkerSize',4);

dets = detect(scenario);

% Plot the clutter region, which in this case is simply the beam footprint, along with the detection positions. 
% Since the land surface used here is unbounded, the plotSurface call should come last so that the surface plot extends 
% over the appropriate axis limits. The clutterRegionData method on the clutter generator is used to get plot data 
% for the clutter region plotter. Similarly, for the surface plotter, 
% the surfacePlotterData method on the scenario surface manager is used.

% plotClutterRegion(clutPlotter,clutterRegionData(clut))
% detpos = cell2mat(cellfun(@(t) t.Measurement(1:3).',dets,'UniformOutput',0));
% plotDetection(detPlotter,detpos)
% plotSurface(surfPlotter,surfacePlotterData(scenario.SurfaceManager))

%% Simulate Clutter IQ Signals
% Now you will create a radarTransceiver with similar radar system parameters and simulate clutter at the signal level. 
% The function helperMakeTransceiver is provided to quickly create a transceiver with the desired system parameters.

% Define the desired beamwidth. For comparison to the above scenario, simply 
% let the beamwidth equal the field of view that was used.

beamwidth3dB = fov;

useCustomElem = true;
rdriq = helperMakeTransceiver(beamwidth3dB,fc,rngRes,prf,useCustomElem);

rdriq.MountingAngles = mountAng;
rdriq.NumRepetitions = numPulses;

release(rdrTraj)
scenario = radarScenario('UpdateRate',0,'IsEarthCentered',false);
platform(scenario,'Sensors',rdriq,'Trajectory',rdrTraj);
landSurface(scenario,'RadarReflectivity',refl);

clutterGenerator(scenario,rdriq,'Resolution',clutRes,'UseBeam',false,'RangeLimit',clutRngLimit);

clut = getClutterGenerator(scenario,rdriq);

beamwidthNN = 2.5*beamwidth3dB;
minel = -mountAng(2) - beamwidthNN(2)/2;
minrad = -rdrAlt/tand(minel);

maxrad = sqrt(clut.RangeLimit^2 - rdrAlt^2);

azspan = beamwidthNN(1);
azc = 0;
ringClutterRegion(clut,minrad,maxrad,azspan,azc)

% helperPlotGroundProjectedPattern(clut)

iqsig = receive(scenario);
PH = iqsig{1};

% figure
% helperPlotRDM(PH,rngRes,prf,numPulses)
% 
% helperTheaterPlot(clut)

%% Simulate Surface Range Profiles for a Scanning Radar
% The automatic mainlobe clutter option supports scanning radars. In this section you will re-create the scenario 
% to use a stationary scanning linear array that collects a single pulse per scan position. 
% You will add a few stationary surface targets and view the resulting range profiles.
% Start by re-creating the radar object. This time, only pass the azimuth beamwidth to the helper function, 
% which indicates a linear array should be used. The custom element cannot be used for a linear array 
% if the automatic mainlobe clutter option is being used, so that the ClutterGenerator has knowledge of the array geometry. 
% Reduce the range resolution to 75 meters to reduce the clutter power in gate.

useCustomElem = false;
rngRes = 75;
rdriq = helperMakeTransceiver(beamwidth3dB(1),fc,rngRes,prf,useCustomElem);

numPulses = 1;
rdriq.MountingAngles = mountAng;
rdriq.NumRepetitions = numPulses;

rdriq.ElectronicScanMode = 'Sector';
rdriq.ElectronicScanLimits = [-30 30;0 0];      % 범위 변경 가능
rdriq.ElectronicScanRate = [prf; 0];

scenario = radarScenario('UpdateRate',0,'IsEarthCentered',false,'StopTime',60/prf);     % prf앞의 숫자 단위를 변경
platform(scenario,'Sensors',rdriq,'Position',rdrPos,'Orientation',rotz(90).');
landSurface(scenario,'RadarReflectivity',refl);

clutterGenerator(scenario,rdriq,'Resolution',clutRes,'UseBeam',true,'RangeLimit',clutRngLimit);

tgtRCS = 40; % dBsm
platform(scenario,'Position',[8e3 -2e3 0],'Signatures',rcsSignature('Pattern',tgtRCS));
platform(scenario,'Position',[8e3    0 0],'Signatures',rcsSignature('Pattern',tgtRCS));
platform(scenario,'Position',[8e3  2e3 0],'Signatures',rcsSignature('Pattern',tgtRCS));

rangeGates = (0:ceil((unambRange-rngRes)/rngRes))*rngRes;
frame = 0;
while advance(scenario)
    frame = frame + 1;
    
    [iqsig,info] = receive(scenario);
    
    lookAng(:,frame) = info.ElectronicAngle;
    rangeProfiles(:,frame) = 20*log10(abs(sum(iqsig{1},2)));
    
    if frame == 1
        % Initial plotting
        ax(1) = subplot(1,2,1);
        helperPlotClutterScenario(scenario,[],[],ax(1))        
        ax(2) = subplot(1,2,2);
        rpHndl = plot(ax(2),rangeGates/1e3,rangeProfiles(:,frame));
        tHndl=title(sprintf('Frame: %d, Azimuth: %.1f deg',frame,lookAng(1,frame)));
        grid on
        xlabel('Range (km)')
        ylabel('Range Profile (dBW)')
    else
        % Update plots
        helperPlotClutterScenario(scenario,[],[],ax(1))
        rpHndl.YData = rangeProfiles(:,frame);
        tHndl.String = sprintf('Frame: %d, Azimuth: %.1f deg',frame,lookAng(1,frame));
    end
    
    drawnow limitrate nocallbacks
end 

figure
imagesc(lookAng(1,:),rangeGates/1e3,rangeProfiles);
set(gca,'ydir','normal')
xlabel('Azimuth Scan Angle (deg)')
ylabel('Range (km)')
title('Clutter Range Profiles (dBW)')
colorbar

%% Simulate Smooth Surface Clutter for a Range-Doppler Radar
% Up till now you have simulated surface clutter using the "uniform" scatterer distribution mode. For flat-Earth scenarios,
% the radarTransceiver radar model, and smooth surfaces (no terrain or spectral model associated with the surface),
% a faster range-Doppler-adaptive mode is available which uses a minimal number of clutter scatterers
% and a more accurate calculation of the clutter power in each range-Doppler resolution cell.

% Re-create the radarTransceiver, again with a linear array. The automatic mainlobe region will not be used in this section,
% so use a custom element to speed things up.

useCustomElem = true;
rdriq = helperMakeTransceiver(beamwidth3dB(1),fc,rngRes,prf,useCustomElem);

numPulses = 64;
rdriq.MountingAngles = mountAng;
rdriq.NumRepetitions = numPulses;

scenario = radarScenario('UpdateRate',0,'IsEarthCentered',false);
landSurface(scenario,'RadarReflectivity',refl);

release(rdrTraj)
platform(scenario,'Sensors',rdriq,'Trajectory',rdrTraj);

clut = clutterGenerator(scenario,rdriq,'ScattererDistribution','RangeDopplerCells','UseBeam',false,'RangeLimit',clutRngLimit);
ringClutterRegion(clut,minrad,maxrad,60,0);

platform(scenario,'Position',[8e3 -2e3 0],'Signatures',rcsSignature('Pattern',tgtRCS));
platform(scenario,'Position',[8e3    0 0],'Signatures',rcsSignature('Pattern',tgtRCS));
platform(scenario,'Position',[8e3  2e3 0],'Signatures',rcsSignature('Pattern',tgtRCS));

iqsig = receive(scenario);
PH = iqsig{1};
helperPlotRDM(PH,rngRes,prf,numPulses);

%% Clutter from Terrain Data
% In the previous sections, you simulated homogeneous clutter from an unbounded flat surface. In this section, 
% you will use a DTED file to simulate clutter return from real terrain data in an Earth-centered scenario. 
% You will collect two frames of clutter return - one with shadowing enabled and one without shadowing, and compare the results.
% Start by creating the scenario, this time setting the IsEarthCentered flag to true in order to use a DTED file, 
% which consists of surface height samples over a latitude/longitude grid.

scenario = radarScenario('UpdateRate',0,'IsEarthCentered',true);

refLLA = [39.43; -105.84];
bdry = refLLA + [0 1;-1/2 1/2]*0.15;

% 창도군 지역 DTED 적용 법 알아볼 것
srf = landSurface(scenario,'Terrain','n39_w106_3arc_v2.dt1','Boundary',bdry,'RadarReflectivity',refl);

srfHeight = height(srf,refLLA);
rdrAlt = srfHeight + rdrAlt;
rdrPos1 = [refLLA; rdrAlt];

rdrVelWest = [-rdrSpd 0 0];

toa = [0;1];    % Times of arrival at each waypoint
rdrPos2 = enu2lla(rdrVelWest,rdrPos1.','ellipsoid').';      % 레이더 속도가 ENU로 표현되었기에 LLA로 변환(DEM 형식)
rdrTrajGeo = geoTrajectory('Waypoints',[rdrPos1, rdrPos2].','TimeOfArrival',toa,'ReferenceFrame','ENU');
platform(scenario,'Sensors',rdriq,'Trajectory',rdrTrajGeo);

clut = clutterGenerator(scenario,rdriq,'Resolution',clutRes,'UseBeam',false,'RangeLimit',clutRngLimit);

ringClutterRegion(clut,minrad,maxrad,azspan,azc);

iqsig = receive(scenario);
PH_withShadowing = iqsig{1};

helperPlotClutterScenario(scenario)
title('Clutter patches - with terrain shadowing')

figure
subplot(1,2,1)
helperPlotRDM(PH_withShadowing,rngRes,prf,numPulses)
title('RDM - with terrain shadowing')
subplot(1,2,2)
helperPlotRDM(PH_noShadowing,rngRes,prf,numPulses)
title('RDM - without terrain shadowing')
set(gcf,'Position',get(gcf,'Position')+[0 0 560 0])

% Conclusion
% In this example, you saw how to configure a radar scenario to include clutter return as part of the detect and receive methods,
% generating clutter detections and IQ signals with the radarDataGenerator and radarTransceiver, respectively. 
% You saw how to define a region of the scenario surface with an associated reflectivity model, 
% and how to specify regions of interest for clutter generation. Surface shadowing is simulated 
% when generating clutter returns from surfaces with terrain, and a faster range-Doppler-adaptive mode can be used 
% for flat-Earth scenarios with smooth surfaces.
%% 

% clear;
% clc;
% close all;
% 
% % 레이더 및 클러터 설정
% Nele = 4;
% c = physconst('Lightspeed');
% fc = 300.0e6;
% lambda = c/fc;
% array = phased.ULA('NumElements',Nele,'ElementSpacing',lambda/2);
% fs = 1.0e6;
% prf = 10.0e3;
% height = 1000.0;
% direction = [90;0];
% speed = 2.0e3;
% depang = 30.0;
% mountingAng = [depang,0,0];
% 
% % 클러터 시뮬레이션 객체 생성
% Rmax = 5000.0;
% Azcov = 120.0;
% tergamma = 0.01; % 감마 값 설정 (클러터 반사율)
% tpower = 5000.0;
% clutter_test = constantGammaClutter('Sensor',array,...
%     'PropagationSpeed',c,'OperatingFrequency',fc,'PRF',prf,...
%     'SampleRate',fs,'Gamma',tergamma,'EarthModel','Flat',...
%     'TransmitERP',tpower,'PlatformHeight',height,...
%     'PlatformSpeed',speed,'PlatformDirection',direction,...
%     'MountingAngles',mountingAng,'ClutterMaxRange',Rmax,...
%     'ClutterAzimuthSpan',Azcov,'SeedSource','Property',...
%     'Seed',40547);
% 
% % 10개의 펄스에 대한 클러터 신호 시뮬레이션
% Nsamp = fs/prf;
% Npulse = 10;
% sig = zeros(Nsamp,Nele,Npulse);
% for m = 1:Npulse
%     sig(:,:,m) = clutter_test();
% end
% 
% % 클러터 신호 생성 (평균 펄스)
% clutterSig = zeros(Nsamp, Nele);
% for m = 1:Npulse
%     clutterSig = clutterSig + abs(clutter_test());
% end
% clutterSig = clutterSig / Npulse;
% 
% % 신호 전력 및 클러터 전력 계산
% signalPower = mean(abs(sig(:)).^2);        % 신호 전력 계산
% clutterPower = mean(abs(clutterSig(:)).^2); % 클러터 전력 계산
% 
% % SNR 계산
% SNR = 10 * log10(signalPower / clutterPower);
% disp(['SNR: ', num2str(SNR), ' dB']);
% 
% % 각도-도플러 응답 표시
% response = phased.AngleDopplerResponse('SensorArray',array,...
%     'OperatingFrequency',fc,'PropagationSpeed',c,'PRF',prf);
% plotResponse(response,shiftdim(sig(20,:,:)),'NormalizeDoppler',true)

%% surfacegamma - gamma value for different terrains

fc = 3e9;
g = surfacegamma('Flatland',fc);
clutter_2 = constantGammaClutter('Gamma',g, ...
     ...
    'OperatingFrequency',fc);
x = clutter_2();
r = (0:numel(x)-1)/(2*clutter_2.SampleRate) * ...
    clutter_2.PropagationSpeed;
plot(r,abs(x))
xlabel('Range (m)')
ylabel('Clutter Magnitude (V)')
title('Clutter Return vs. Range')

%% test 2

  fc = 300e6;
  g = surfacegamma('woods',fc);
  hclutter = constantGammaClutter('Gamma',g,...
          'Sensor',phased.CosineAntennaElement,'OperatingFrequency',fc);
  x = step(hclutter);
  r = (0:numel(x)-1)/(2*hclutter.SampleRate)*hclutter.PropagationSpeed;
  plot(r,abs(x)); xlabel('Range (m)'); ylabel('Clutter Magnitude (V)');
  title('Clutter Return vs. Range');
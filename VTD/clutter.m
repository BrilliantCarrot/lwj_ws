clear;
clc;
close all;

%% constantGammaClutter에 대한 매트랩 예시

%% --------------------Simulate Clutter for System with Known Power--------------------

% Simulate the clutter return from terrain with a gamma value of 0 dB. The effective transmitted power of the radar system is 5 kW.

% Set up the characteristics of the radar system. This system uses a four-element uniform linear array (ULA). The sample rate is 1 MHz, 
% and the PRF is 10 kHz. The propagation speed is the speed of light, and the operating frequency is 300 MHz. 
% The radar platform is flying 1 km above the ground with a path parallel to the ground along the array axis. 
% The platform speed is 2 km/s. The mainlobe has a depression angle of 30°.

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
sig = zeros(Nsamp,Nele,Npulse);
for m = 1:Npulse    % 각 펄스에 대해 클러터 신호를 생성
    sig(:,:,m) = clutter_1();
end

% Plot the angle-Doppler response of the clutter at the 20th range bin.

response = phased.AngleDopplerResponse('SensorArray',array,...
    'OperatingFrequency',fc,'PropagationSpeed',c,'PRF',prf);
plotResponse(response,shiftdim(sig(20,:,:)),'NormalizeDoppler',true)

%% Range-Doppler 에서 시각화

% Reshape the signal matrix to match the required format
sig2D = reshape(sig, Nsamp, Nele * Npulse);

% Create the Range-Doppler response object without PRF
response = phased.RangeDopplerResponse('RangeMethod', 'FFT', 'DopplerOutput', 'Frequency', 'SampleRate', fs);

% Compute and plot the Range-Doppler map
plotResponse(response, sig2D);

%% --------------------Simulate Clutter Using Known Transmit Signal--------------------

% Simulate the clutter return from terrain with a gamma value of 0 dB. You input the transmit signal of the radar system when creating clutter. 
% In this case, you do not use the TransmitERP property.

%Set up the characteristics of the radar system. This system has a 4-element uniform linear array (ULA). 
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
% The configuration assumes the earth is flat. The maximum clutter range of interest is 5 km, and the maximum azimuth coverage is ±60°.

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
% The software computes the effective transmitted power of the signal. The transmit signal is a rectangular waveform with a pulse width of 2 μs.

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

%% surfaceReflectivityLand를 통한 Constant Gamma Clutter 구현 예시

%% Select a Radar Model

mountAng = [-90 10 0];
fc = 5e9;
rngRes = 150;
prf = 12e3;
numPulses = 64;
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

%% Create a Scenario

scenario = radarScenario('UpdateRate',0,'IsEarthCentered',false);

rdrAlt = 1.5e3;
rdrSpd = 70;
rdrDiveAng = 10;
rdrPos = [0 0 rdrAlt];
rdrVel = rdrSpd*[0 cosd(rdrDiveAng) -sind(rdrDiveAng)];
rdrOrient = rotz(90).';
rdrTraj = kinematicTrajectory('Position',rdrPos,'Velocity',rdrVel,'Orientation',rdrOrient);
rdrplat = platform(scenario,'Sensors',rdr,'Trajectory',rdrTraj);

%% Define the Scenario Surface

% Create a simple unbounded land surface with a constant-gamma reflectivity model. Use the surfaceReflectivityLand function 
% to create a reflectivity model and attach the reflectivity model to the surface with the RadarReflectivity parameter. 
% Use a gamma value of -20 dB.

refl = surfaceReflectivityLand('Model','ConstantGamma','Gamma',-20);
srf = landSurface(scenario,'RadarReflectivity',refl);


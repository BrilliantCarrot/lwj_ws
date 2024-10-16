


%% 함수만 나중에 따로 떼서 사용


function helperPPMCalc(dist, azi, ele)



% 거리, 기상 상황(배경 투명도), 수직이착륙기 기하(고가 및 방위각)을 입력받아 그 상황의 수직이착륙기 픽셀 수를 반환
% dist: 레이더로부터 수직이착륙기 까지의 거리
% azi: 레이더가 바라본 수직이착륙기 방위각 기하
% ele: 레이더가 바라본 수직이착륙기 고각 기하

% refPixel: 비율을 구하기위해 계산할 기준 픽셀 수(clear 상황에서 구한 픽셀 수 이며
% 지수 함수 피팅 모델의 파라미터 또한 clear 상황의 거리를 기준으로 작성함)
% minPixelcnt: 보이고 안 보이고의 가시성을 판단할 최소 픽셀 수(DORI의 25 ppm)
% originalPixel: 비율과 곱해질 원 테이틀의 픽셀 값

refPixel = 202;
minPixelCnt = 25;
originalPixel = userTable(ele,azi);

% 사전에 미리 구한 이중 지수 함수의 파라미터를 이용
a = 20276.7791;
b = -0.0075;
c = 1114.5824;
d = -0.0015;

double_exp_model = @(x) a * exp(b * x) + c * exp(d * x);    % 지수 함수 피팅 모델

calculated_pixel = double_exp_model(dist);  % 비율을 구하기 위해 사용자가 입력한 거리에서 구해진 픽셀 수
pixelRatio = calculated_pixel/refPixel;     % 두 변수를 통해 비율을 계산
finalPPM = pixelRatio * originalPixel;     % 구한 비율을 특정 기상 상황 및 특정 기하에서의 픽셀과 곱함

disp(['계산된 PPM 값: ', num2str(finalPPM)]);

if finalPixelcnt > minPixelCnt
    disp("목표가 식별 됨");
end
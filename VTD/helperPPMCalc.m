% 테이블을 먼저 입력받음

clar_table = 'C:/Users/leeyj/lab_ws/data/vtd/EO/clear/clear sky.xlsx';
sheet = 1;  % 첫 번째 시트
data = readmatrix(clear_table, 'Sheet', sheet);

% 날씨 상황을 입력받음
weather = input('Enter the weather condition (clear, cloudy, rain): ', 's');

% clar_table = 'C:/Users/leeyj/lab_ws/data/vtd/EO/clear/clear sky.xlsx';
% sheet = 1;  % 첫 번째 시트
% data = readmatrix(clear_table, 'Sheet', sheet);

%% 함수만 나중에 따로 떼서 사용


function PPM = helperPPMCalc(dist, azi, ele, weather, background)



% 거리, 기상 상황(배경 투명도), 수직이착륙기 기하(고가 및 방위각)을 입력받아 그 상황의 수직이착륙기 픽셀 수를 반환
% dist: 레이더로부터 수직이착륙기 까지의 거리
% azi: 레이더가 바라본 수직이착륙기 방위각 기하
% ele: 레이더가 바라본 수직이착륙기 고각 기하
% weather: 기상 상황(배경 투명도), 맑은 날, 약한 비, 강한 비, 안개, 구름, 눈
% background: 수직이착륙기 뒤의 배경, 황무지, 숲, 눈, 하늘 존재
% minPixelcnt: 보이고 안 보이고의 가시성을 판단할 최소 픽셀 수

% 입력 파라미터의 날씨 및 배경에 따라 조건문을 거쳐 테이블을 선정
if strcmpi(weather, 'clear')
    % 각 날씨상황에 맞는 table을 입력받음
    % table = clear_table;

elseif strcmpi(weather, 'cloudy')
    disp('The weather is cloudy. It might rain later.');
    % cloudy에 해당하는 추가 작업 수행
elseif strcmpi(weather, 'rain')
    disp('It is raining. Take an umbrella!');
    % rain에 해당하는 추가 작업 수행
else
    disp('Invalid input. Please enter clear, cloudy, or rain.');
    % 잘못된 입력 처리
end



if finalPixelcnt > minPixelcnt
    disp("Detected");

% PPM = abs(sqrt(x^2 + y^2 + z^2)); 등의 계산 예시
% disp(PPM)
end
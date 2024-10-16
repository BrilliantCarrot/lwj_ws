% IR영상 이미지에 대해 detectability를 활용하여 기하 마다의 픽셀 수 테이블을 생성

% 알고리즘대로 각각의 배경에 대해 Detectability를 제대로 산출하기 위해서
% 헬기를 촬영할 시의 캡처 화면 크기를 전부 동일하게 설정하는것이 중요함
% 이미지의 가로, 세로 사이즈를 기반으로 평균을 내기 때문

%% << Detectability >>
%% 1. 이미지 파일 하나에 대해 detectability factor를 적용 

clear;
clc;

all = imread("C:/Users/leeyj/lab_ws/data/VTD/IR/images_set/winter/40/09.png");    % 헬기 및 배경을 모두 포함하는 이미지
all_temp = all;    % 픽셀 비교 임시 이미지(헬기 영역만 픽셀 값이 없는 이미지)를 위한 위의 복사본
land = imread("C:/Users/leeyj/lab_ws/data/VTD/IR/images_set/winter/background.png");    % 지표에 대한 정보만을 포함하는 이미지

all_gray = rgb2gray(all);                   % rgb2gray 결과는 0~255의 값을 가짐
all_temp_gray = rgb2gray(all);
land_gray = rgb2gray(land);

all_double = im2double(all_gray);               % 0~1 사이의 값으로 변환
all_temp_double = im2double(all_temp_gray);
land_double = im2double(land_gray);

all_norm = 256*all_double;                 % 정규화
all_temp_norm = 256*all_temp_double;
land_norm = 256*land_double;

all_sum = sum(all_norm(:));                 % 픽셀값의 총 합 구하기
land_sum = sum(land_norm(:));
heli_only_sum = all_sum - land_sum;

[rows,cols] = size(all_gray);

% 지형 배경과 헬기를 포함하는 모든 이미지의 차이를 구함
% 차이가 존재하면 헬기 영역이기에 그 영역을 0으로 만듦
heli_diff = all_norm - land_norm; 
for i = 1:rows
    for j = 1:cols
        if heli_diff(i,j) ~= 0
            all_temp_gray(i,j) = 0;     % 헬기 영역이 0으로 표현된 테이블
            % fprintf('i = %d, j = %d\n', i, j);
        end
    end
end

% 0으로 만든 이미지와 원래 이미지를 빼면 헬기에 해당하는 영역만이 나옴
heli_only = all_gray - all_temp_gray;
% land_only = all_gray - heli_only;
land_only = all_gray - heli_only;

% 평균을 구하기 위해 헬기 및 지표만의 픽셀들의 개수를 구하기 위한 count 변수 설정
heli_cnt = 0;
land_cnt = 0;

% 반복문을 통해 헬기만의 픽셀 수와 지표만의 픽셀 수를 구함
for i = 1:rows
    for j = 1:cols
        if heli_only(i,j) ~= 0
            heli_cnt = heli_cnt + 1;
        end
        if land_only(i,j) ~= 0
            land_cnt = land_cnt + 1;
        end
    end
end

% 평균을 구한 값을 통하여 detectability 산출
% 0~1까지의 정규화를 수행한 값이므로 타당
% 하나의 값을 사용한다 가정하기 위하여 평균값을 이용
diff = abs(sum(land_only(:))/land_cnt - sum(heli_only(:))/heli_cnt);
disp(diff)

% 헬기에 해당하는 영역을 1로, 아닌영역을 0으로 이진화 시켜 헬기만 검출된게 맞는지 확인
% for i = 1:500
%     for j = 1:500
%         if heli_only(i,j) ~= 0
%             heli_only(i,j) = 1;
%         end
%     end
% end
% figure
% imshow(heli_only,[])


%% 2. 폴더 내 이미지 파일들에 대해 알고리즘을 적용

clc;
clear;

% 경로 설정
folder_path = 'C:/Users/leeyj/lab_ws/data/vtd/IR/images_set/spring/40/%02d.png';  % 모든 이미지가 있는 폴더 경로
land_path = 'C:/Users/leeyj/lab_ws/data/VTD/IR/images_set/spring/background.png';          % 배경 이미지 경로

num_files = 19;  % 처리할 이미지 수
results_diff = zeros(num_files, 1);   % diff 값을 저장할 배열
results_heli_cnt = zeros(num_files, 1);  % 헬리콥터 픽셀 개수를 저장할 배열
results_land_cnt = zeros(num_files, 1);  % 배경 픽셀 개수를 저장할 배열
reults_final = zeros(num_files,1);

% 배경 이미지 로드 (변하지 않음)
land = imread(land_path);
land_gray = rgb2gray(land);
land_double = im2double(land_gray);
land_norm = 256 * land_double;
land_sum = sum(land_norm(:));

% 반복문을 통해 각 이미지를 처리
for i = 1:num_files
    % 이미지 파일 경로 생성 및 읽기
    img_path = sprintf(folder_path, i-1);  % 00.png, 01.png, ... , 18.png, 19.png
    all = imread(img_path);
    
    % 전처리 과정
    all_gray = rgb2gray(all);
    all_double = im2double(all_gray);
    all_norm = 256 * all_double;
    
    % 픽셀 값 총합 계산
    all_sum = sum(all_norm(:));
    heli_only_sum = all_sum - land_sum;
    
    % 헬기 영역 구하기
    heli_diff = all_norm - land_norm;
    all_temp_gray = all_gray;
    
    [rows, cols] = size(all_gray);
    for r = 1:rows
        for c = 1:cols
            if heli_diff(r, c) ~= 0
                all_temp_gray(r, c) = 0; % 헬기 영역을 0으로 설정
            end
        end
    end
    
    % 헬기와 배경만의 이미지 생성
    heli_only = all_gray - all_temp_gray;
    land_only = all_gray - heli_only;
    
    % 헬리콥터 및 배경 픽셀 수 초기화
    heli_cnt = 0;
    land_cnt = 0;
    
    % 헬리콥터와 배경 픽셀 수 계산
    for r = 1:rows
        for c = 1:cols
            if heli_only(r, c) ~= 0
                heli_cnt = heli_cnt + 1;
            end
            if land_only(r, c) ~= 0
                land_cnt = land_cnt + 1;
            end
        end
    end
    
    % 피탐성을 나타내는 diff 계산
    diff = abs(sum(land_only(:)) / land_cnt - sum(heli_only(:)) / heli_cnt);
    if diff > 100
        diff = 100-(diff-100);
    end    
    
    results_diff(i) = diff;
    results_heli_cnt(i) = heli_cnt;
    results_land_cnt(i) = land_cnt;
    
    % % 진행 상태 출력
    % fprintf('Processed image %d/%d: diff = %.4f, Helicopter Pixels = %d, Land Pixels = %d\n', ...
    %     i, num_files, diff, heli_cnt, land_cnt);
end

results_table_1 = table((0:num_files-1)', results_diff, results_heli_cnt, results_land_cnt, ...
    'VariableNames', {'ImageIndex', 'Diff', 'HelicopterPixelCount', 'LandPixelCount'});
for i = 1:19
    results_final(i) = (results_heli_cnt(i)/25)*(results_diff(i)/100);
end

disp(results_table_1);
disp(round(results_final'))
disp(mean(diff))


%% << 함수화 >>

% 입력 파라미터에 대한 적용
% 입력은 수직이착륙기 관련 데이터 및 배경에 대한 정보
% ? 기하도 고려
% 수직이착륙기의 경우: 수직이착륙기의 대략적인 온도 및 기하
% 배경의 경우: 배경 요소(봄, 여름, 가을, 겨울, 구름, 대기)






helperIRDetectability(heliTemp, background);

%% 한 폴더에 대해

clear;
clc;
close all;

path = './test/%02d.png';
num_images = 6;
temperature_data = cell(num_images, num_images);

for col = 1:num_images
    for row = 1:num_images
        img_path = sprintf(path, row-1);                        % 이미지 파일 이름 생성 후 읽기
        img = imread(img_path);
        hei_gray = rgb2gray(img);
        heli_double = im2double(hei_gray);
        temp_pixel = 256 * heli_double;
        temperature_data{row, col} = temp_pixel;
    end
end

%% 반복문으로 모든 경로의 폴더에 대해 수행

clear;
clc;
close all;

folders = 0:10:180;
num_images = 19;
temperature_data = cell(num_images, num_images);

for col = 1:num_images
    folder_path = sprintf('./IR/temp/%d/', folders(col));
    for row = 1:num_images
        img_path = sprintf('%s%02d.png', folder_path, row-1);
        img = imread(img_path);
        hei_gray = rgb2gray(img);
        heli_double = im2double(hei_gray);
        temp_pixel = 256 * heli_double;
        temperature_data{row, col} = temp_pixel;
    end
end

%% 결과 확인
close all
for row = 1:num_images
    figure;
    imshow(temperature_data{row, 13}, []);                      % 원하는 열 입력
    title(sprintf('Image %02d from the folder', row-1));
end

%%

img = imread('C:/Users/leeyj/Unity/VTD Project/Assets/3D Haven/Free Fantasy Terrain Textures/Textures/2K Resolution/Temp/3DH FTT Path_001 2K.png');
hei_gray = rgb2gray(img);

img_rgb = cat(3, hei_gray, hei_gray, hei_gray);

img_hsv = rgb2hsv(img_rgb);
V_1 = img_hsv(:,:,3);
% V 값을 0부터 255 범위로 변환 (정수형으로 변환)
V_scaled = uint8(V_1 * 255);

% disp(['최소 V 값: ', num2str(min(V_scaled(:)))]);
% disp(['최대 V 값: ', num2str(max(V_scaled(:)))]);

% 결과로 얻은 V 값을 다시 0부터 1 범위로 정규화
img_hsv(:,:,3) = double(V_scaled) / 255;
img_hsv(:,:,3) = img_hsv(:,:,3) * 2;
V_2 = img_hsv(:,:,3);

img_result = hsv2rgb(img_hsv);
% figure
% imshow(img_rgb);
% figure
% imshow(img_hsv)
figure
imshow(img_result)

%%

img = imread('C:/Users/leeyj/Unity/VTD Project/Assets/3D Haven/Free Fantasy Terrain Textures/Textures/2K Resolution/Temp/3DH FTT Path_001 2K.png');
img_hsv = rgb2hsv(img);
value = 255;
img_hsv(:,:,3) = double(value) / 255;
disp(['설정된 V 값: ', num2str(value)]);
img_result = hsv2rgb(img_hsv);
figure
imshow(img_result)

%%

% RGB 이미지 불러오기
rgbImage = imread('C:/Users/leeyj/Unity/VTD Project/Assets/3D Haven/Free Fantasy Terrain Textures/Textures/2K Resolution/Temp/3DH FTT Path_001 2K.png');

% 회색조 이미지로 변환
grayImage = rgb2gray(rgbImage);

% 회색조 이미지를 0~255 사이의 값으로 정규화
normalizedImage = double(grayImage);
normalizedImage = (normalizedImage - min(normalizedImage(:))) / (max(normalizedImage(:)) - min(normalizedImage(:))) * 255;

% 원하는 value로 설정
desiredValue = 10;  % 원하는 값을 지정하세요
normalizedImage(:) = desiredValue;

% 결과 이미지 출력
imshow(uint8(normalizedImage));

%% 
% temp{1,1} = temp_pixel;
% temperature_data{row, col} = temp_pixel;
% for i = 1:500
%     for j = 1:500
% 
%         if temp_pixel(i,j) < 53
%             temp_pixel(i,j) = nan;
%         end
%     end
% end
% T_sig = sum(sum(temp_pixel));
% max(max(temp_pixel))
% min(min(temp_pixel))


%% IR영상 이미지를 불러온 후 temperature_date 셀에 저장

% IR 쪽 진행해야될 내용
% 논문에 맞게 색칠을 하고
% 기하를 이전에 했던 테이블 대로 맞춰서 테이블 형태의 데이터를 만들되(테이블 내용은 temp_pixel)
% 그 테이블을 밑의 코드대로 셀 형식으로 기존 엑셀의 테이블과 같은 구조를 만들음

%% 이미지 파일 하나만 예시로 

clear;
clc;
close all;

all = imread("C:/Users/leeyj/lab_ws/data/VTD/IR/temp/대기및헬기.png");    % 헬기 및 배경을 모두 포함하는 이미지
all_temp = all;    % 픽셀 비교 임시 이미지(헬기 영역만 픽셀 값이 없는 이미지)를 위한 위의 복사본
land = imread("C:/Users/leeyj/lab_ws/data/VTD/IR/temp/대기.png");    % 지표에 대한 정보만을 포함하는 이미지

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

% 지형 배경과 헬기를 포함하는 모든 이미지의 차이를 구함
% 차이가 존재하면 헬기 영역이기에 그 영역을 0으로 만듦
% 500 X 500 이미지에 대해 반복문을 통해 수행
heli_diff = all_norm - land_norm; 
for i = 1:500
    for j = 1:500
        if heli_diff(i,j) ~= 0
            all_temp_gray(i,j) = 0;
        end
    end
end

% 0으로 만든 이미지와 원래 이미지를 빼면 헬기에 해당하는 영역만이 나옴
heli_only = all_gray - all_temp_gray;
land_only = all_gray - heli_only;

% 평균을 구하기 위해 헬기 및 지표만의 픽셀들의 개수를 구하기 위한 count 변수 설정
heli_cnt = 0;
land_cnt = 0;

% 반복문을 통해 헬기만의 픽셀 수와 지표만의 픽셀 수를 구함
for i = 1:500
    for j = 1:500
        if heli_only(i,j) ~= 0
            heli_cnt = heli_cnt + 1;
        end
        if land_only(i,j) ~= 0
            land_cnt = land_cnt + 1;
        end
    end
end

% 평균을 구한 값을 통하여 detectability 산출
diff = abs(sum(land_only(:))/land_cnt - sum(heli_only(:))/heli_cnt);

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

clear
clc
close all

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




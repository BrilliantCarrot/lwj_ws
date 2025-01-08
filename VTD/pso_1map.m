function [gBest_value,final_cal_time] = pso_1map(path, Start, Goal ,map_name_in, k, scen_no)
map_name = convertCharsToStrings(map_name_in); 
k_str = num2str(k);
fprintf("map number :" + map_name + "\n");
fprintf("Case : %i \n", k);
heightmap_RGB = imread(path + "\" + map_name);

%% start goal auto(필요 없으면 변수삭제후 주석처리)
% [h,v,c]=size(heightmap_RGB);
% Start = [round(v*0.1),round(h*0.1)+100];
% Goal = [round(v*0.9),round(h*0.9)];
%%
iter = 5;
final_cal_time = 0;
final_waypoints = 0;
final_gBest_value = 0;

for i = 1:iter
    [cal_time, waypoints, gBest_value]=PSO_multi(heightmap_RGB,Start,Goal);
    update = 0;
    if i == 1
        final_cal_time = cal_time;
        final_waypoints = waypoints;
        final_gBest_value = gBest_value;
        update = 1;
    elseif (gBest_value < final_gBest_value)
        final_cal_time = cal_time;
        final_waypoints = waypoints;
        final_gBest_value = gBest_value;
        update = 1;
    end
    % fprintf('iteration : %.2f \n', i);
    % if update == 1
    %     fprintf('updating... \n');
    %     fprintf('final_cal_time : %.2f \n', final_cal_time);
    %     % fprintf('final_waypoints : %.2f \n', final_waypoints);
    %     fprintf('final_gBest_value : %.2f \n', final_gBest_value);
    % else
    %     fprintf('cal_time : %.2f \n', cal_time);
    % end
    

end
%% 데이터 처리
if k == 1
    fileID = fopen(path  + "\figure\" + map_name + ".txt", 'w');
else
    fileID = fopen(path  + "\figure\" + map_name + ".txt", 'a');
end

fprintf(fileID, k + " : [");

for j = 1:length(final_waypoints(:,1))-1
    fprintf(fileID,"(%.2f,%.2f), ", final_waypoints(j,:));
end
fprintf(fileID,"(%.2f,%.2f)] \n", final_waypoints(j+1,:));

% fprintf(fileID,'final_cal_time : %.2f \n', final_cal_time);
% fprintf(fileID,'final_distance_ratio : %.2f \n', final_gBest_value);
% 
% fprintf(fileID,'\n');
fclose(fileID);

% save(path + "\" + map_name + "_result","final_waypoints")
% %% 2D Plotting
% figure;
% % RGB 채널을 분리하여 그레이스케일로 변환
% R = double(heightmap_RGB(1:end,:,1));
% G = double(heightmap_RGB(1:end,:,2));
% B = double(heightmap_RGB(1:end,:,3));
% 
% % 높이값을 정규화
% height2zaxis = length(heightmap_RGB) / 255;
% heightmap_gray = (R * 0.2989 + G * 0.5870 + B * 0.1140) * height2zaxis;
% ms_2 = 6;
% msd_2 = 8;
% imagesc(heightmap_gray);
% set(gca,'YDir','reverse')
% colormap gray; 
% c=colorbar;
% c.Label.String = 'Height';
% hold on
% set(gca,'YDir','normal')
% plot(final_waypoints(:,2), final_waypoints(:,1), 'yo-','MarkerFaceColor','y','MarkerSize',ms_2,'DisplayName','PSO Path')
% plot(Start(2), Start(1),'diamond','MarkerFaceColor','r','MarkerEdgeColor','y','MarkerSize',msd_2,'DisplayName','Start')
% plot(Goal(2), Goal(1),'diamond','MarkerFaceColor','b','MarkerEdgeColor','y','MarkerSize',msd_2,'DisplayName','Goal')
% title('Path Planning by PSO ('+ map_name +')');
% xlabel('X');
% ylabel('Y');
% legend('Location','best')
% hold off
% saveas(gcf,path + "\figure\" + map_name + "_Case_" + scen_no + "_result.fig");
% 
% %% 3D plotting
% offset = 10;
% ms_3 = 8;
% msd_3 = 10;
% lw = 2;
% % RGB 채널을 분리하여 그레이스케일로 변환
% R = double(heightmap_RGB(1:end,:,1));
% G = double(heightmap_RGB(1:end,:,2));
% B = double(heightmap_RGB(1:end,:,3));
% 
% % 높이값을 정규화
% height2zaxis = length(heightmap_RGB) / 255;
% heightmap_gray = (R * 0.2989 + G * 0.5870 + B * 0.1140) * height2zaxis;
% 
% % 최종 높이값 초기화
% final_height = zeros(length(final_waypoints(:,1)), 1);
% 
% % 최종 높이값 계산
% for i = 1:length(final_waypoints(:,1))
%     final_height(i) = heightmap_gray(round(final_waypoints(i,1)), round(final_waypoints(i,2)));
% end
% 
% % 3D 맵 시각화
% figure;
% [X, Y] = meshgrid(1:size(heightmap_gray, 2), 1:size(heightmap_gray, 1)); % X, Y 좌표 생성
% s = surface(X, Y, heightmap_gray, 'LineWidth', 0.00001,'DisplayName', 'Terrain'); 
% s.EdgeColor = [0.2 0.2 0.2]; % 가장자리 색상 설정
% s.LineStyle = ':'; % 가장자리 스타일 설정
% s.FaceColor = 'interp'; % 면 색상 설정
% 
% set(gca, 'YDir', 'normal'); % Y축 방향 설정
% view(3); % 3D 뷰 설정
% hold on;
% 
% % 최종 waypoint 시각화
% plot3(final_waypoints(:, 2), final_waypoints(:, 1), final_height + offset, 'ko-', 'MarkerFaceColor', 'y', 'MarkerSize', ms_3, 'DisplayName', 'PSO Path','LineWidth',lw);
% plot3(final_waypoints(1, 2), final_waypoints(1, 1), final_height(1) + offset, 'diamond', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'MarkerSize', msd_3, 'DisplayName', 'Start');
% plot3(final_waypoints(end, 2), final_waypoints(end, 1), final_height(end) + offset, 'diamond', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'MarkerSize', msd_3, 'DisplayName', 'Goal'); % 목표 waypoint 색상 수정
% 
% title('Path Planning by PSO (' + map_name + ')'); % 제목 설정
% xlabel('X'); % X축 레이블 설정
% ylabel('Y'); % Y축 레이블 설정
% zlabel('Height'); % Z축 레이블 추가
% grid on;
% legend('Location', 'best');
% 
% % 컬러바 추가
% colorbar;
% saveas(gcf, path + "\figure\" + map_name + "_Case_" + scen_no + "_3D_result.fig");

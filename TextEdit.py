import matplotlib.pyplot as plt

# 파일 읽고 줄 바꿈을 콤마로 변경


# # Open and read the text file
# with open('./Assets/Scripts/50_-50.txt', 'r') as file:
#     data = file.read()

# # Replace line breaks with commas
# data = data.replace('\n', ',')

# # Split the string into a list using commas as the delimiter
# your_list = data.split(',')

# # If there's an empty string at the beginning of the list, remove it
# if your_list[0] == '':
#     your_list.pop(0)

# # Now, your_list contains the numbers from the file as individual elements
# # print(your_list)

# with open('./Assets/Scripts/new_50_-50.txt', 'w') as output_file:
#     output_file.write(','.join(your_list))


# 그래프 출력


score_list = []

with open('./Assets/Scripts/new_50_-50.txt', 'r') as file:
    for num_str in file.read().split(','):
        num = float(num_str)
        score_list.append(num)

# print(len(score_list))
# print(score_list)

plt.plot(range(1, len(score_list) + 1), score_list, linestyle='-',color='blue')
plt.xlabel('Episode')
plt.ylabel('Reward')
plt.show()
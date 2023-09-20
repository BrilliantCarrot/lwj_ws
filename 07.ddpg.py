import numpy as np
import random
import copy
import datetime
import platform
import torch
import torch.nn.functional as F
from torch.utils.tensorboard import SummaryWriter
from collections import deque
from mlagents_envs.environment import UnityEnvironment, ActionTuple
from mlagents_envs.side_channel.engine_configuration_channel\
                             import EngineConfigurationChannel

# DDPG를 위한 파라미터 값 세팅
STATE_SIZE = 9
ACTUIB_SIZE = 3

load_model = False
train_mode = True

batch_size = 128
mem_maxlen = 60000
discount_factor = 0.99
actor_lr = 0.0001
critic_lr = 0.001
tau = 1e-3

# OU noise 파라미터
mu = 0
theta = 1e-3
sigma = 2e-3

run_step = 50000 if train_mode else 0
test_step = 10000
train_start_step = 5000

print_interval = 10
save_interval = 100

# 유니티 환경 경로
game = "Drone"
os_name = platform.system()
env_name = f"./Build/{game}"

# 모델 저장 및 불러오기 경로
date_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
save_path = f"./saved_models/{game}/DDPG/{date_time}"
load_path = f"./saved_models/{game}/DDPG/20230914103800"

# 연산 장치
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# ou noise 정의 및 파라미터 결정
class OU_noise:
    def __init__(self):
        self.reset()

    def reset(self):
        self.X = np.ones((1, ACTUIB_SIZE), dtype=np.float32) * mu

    def sample(self):
        dx = theta * (mu - self.X) + sigma * np.random.randn(len(self.X))
        self.X += dx
        return self.X

# 액터 하이퍼 파라미터
class Actor(torch.nn.Module):
    def __init__(self):
        super(Actor, self).__init__()
        self.fc1 = torch.nn.Linear(STATE_SIZE, 128)
        self.fc2 = torch.nn.Linear(128, 128)
        self.mu = torch.nn.Linear(128, ACTUIB_SIZE)

    def forward(self, state):
        x = torch.relu(self.fc1(state))
        x = torch.relu(self.fc2(x))
        return torch.tanh(self.mu(x))

# 크리틱 하이퍼 파라미터
class Critic(torch.nn.Module):
    def __init__(self):
        super(Critic, self).__init__()

        self.fc1 = torch.nn.Linear(STATE_SIZE, 128)
        self.fc2 = torch.nn.Linear(128+ACTUIB_SIZE, 128)
        self.fc3 = torch.nn.Linear(128,128)
        self.q = torch.nn.Linear(128, 1)

    def forward(self, state, action):
        x = torch.relu(self.fc1(state))
        x = torch.cat((x, action), dim=-1)
        x = torch.relu(self.fc2(x))
        # 하이퍼 파라미터 추가
        x = torch.relu(self.fc3(x))
        return self.q(x)

# DDPGAgent 클래스
class DDPGAgent():
    def __init__(self):
        self.actor = Actor().to(device)
        self.target_actor = copy.deepcopy(self.actor)
        self.actor_optimizer = torch.optim.Adam(self.actor.parameters(), lr=actor_lr)

        self.critic = Critic().to(device)
        self.target_critic = copy.deepcopy(self.critic)
        self.critic_optimizer = torch.optim.Adam(self.critic.parameters(), lr=critic_lr)

        self.OU = OU_noise()
        # 강화학습처럼 고정된 메모리 버퍼에서 사용
        self.memory = deque(maxlen=mem_maxlen)
        self.writer = SummaryWriter(save_path)

        if load_model == True:
            print(f"... Load Model from {load_path}/ckpt ...")
            checkpoint = torch.load(load_path+'/ckpt', map_location=device)
            self.actor.load_state_dict(checkpoint["actor"])
            self.target_actor.load_state_dict(checkpoint["actor"])
            self.actor_optimizer.load_state_dict(checkpoint["actor_optimizer"])
            self.critic.load_state_dict(checkpoint["critic"])
            self.target_critic.load_state_dict(checkpoint["critic"])
            self.critic_optimizer.load_state_dict(checkpoint["critic_optimizer"])

    # OU noise 기법에 따라 행동 결정
    def get_action(self, state, training=True):
        #  네트워크 모드 설정
        self.actor.train(training)

        action = self.actor(torch.FloatTensor(state).to(device)).cpu().detach().numpy()
        return action + self.OU.sample() if training else action

    # 리플레이 메모리에 데이터 추가 (상태, 행동, 보상, 다음 상태, 게임 종료 여부)
    def append_sample(self, state, action, reward, next_state, done):
        self.memory.append((state, action, reward, next_state, done))

    def train_model(self):
        batch = random.sample(self.memory, batch_size)
        state      = np.stack([b[0] for b in batch], axis=0)
        action     = np.stack([b[1] for b in batch], axis=0)
        reward     = np.stack([b[2] for b in batch], axis=0)
        next_state = np.stack([b[3] for b in batch], axis=0)
        done       = np.stack([b[4] for b in batch], axis=0)

        # PyTorch 기반 신경망 학습 환경을 설정
        state, action, reward, next_state, done = map(lambda x: torch.FloatTensor(x).to(device),
                                                        [state, action, reward, next_state, done])

        # 크리틱 모델을 업데이트하기 위해 액터 손실값을 계산
        # 타겟 액터가 다음 상태에 따른 다음 행동을 예측
        next_actions = self.target_actor(next_state)
        # 다음 상태-행동 쌍의 Q-가치 추정
        next_q = self.target_critic(next_state, next_actions)
        # 받은 보상에 따라 현재 상태-액션 쌍이 타겟 Q-가치를 계산
        # 미래와 현재의 보상의 정도를 확인
        # done이 1이면 에피소드를 종료
        target_q = reward + (1 - done) * discount_factor * next_q
        # 현재 상태-액션쌍에 따라 크리틱 네트워크가 Q-가치를 수행
        q = self.critic(state, action)
        # 타겟 Q-가치와 예측 Q-가치에 다라 MSE 손실을 계산
        # 크리틱 네트워크 훈련 목표는 손실을 최소화하며 
        # 예측 Q-가치를 타겟 Q-가치에 가깝게 만든다
        critic_loss = F.mse_loss(target_q, q)
        # 액터 모델을 업데이트하기위해 액터 손실값을 계산
        # 경사정도를 0으로 초기화하고 최적화 알고리즘을 통해 신경망 파라미터 업데이트
        self.critic_optimizer.zero_grad()
        critic_loss.backward()
        self.critic_optimizer.step()

        # 액터 업데이트
        action_pred = self.actor(state)
        actor_loss = -self.critic(state, action_pred).mean()
        self.actor_optimizer.zero_grad()
        actor_loss.backward()
        self.actor_optimizer.step()

        return actor_loss.item(), critic_loss.item()

    # 소프트 타겟 업데이트를 위한 함수
    # 타우값에 따라 가중치 타겟 네트워크 업데이트 비율 조정
    def soft_update_target(self):
        for target_param, local_param in zip(self.target_actor.parameters(), self.actor.parameters()):
            target_param.data.copy_(tau * local_param.data + (1.0 - tau) * target_param.data)
        for target_param, local_param in zip(self.target_critic.parameters(), self.critic.parameters()):
            target_param.data.copy_(tau * local_param.data + (1.0 - tau) * target_param.data)

    # 네트워크 모델 저장
    def save_model(self):
        print(f"... Save Model to {save_path}/ckpt ...")
        torch.save({
            "actor" : self.actor.state_dict(),
            "actor_optimizer" : self.actor_optimizer.state_dict(),
            "critic" : self.critic.state_dict(),
            "critic_optimizer" : self.critic_optimizer.state_dict(),
        }, save_path+'/ckpt')

    # 학습 기록
    def write_summray(self, score, actor_loss, critic_loss, step):
        self.writer.add_scalar("run/score", score, step)
        self.writer.add_scalar("model/actor_loss", actor_loss, step)
        self.writer.add_scalar("model/critic_loss", critic_loss, step)

if __name__ == '__main__':
    # 유니티 환경 경로 설정 (file_name)
    engine_configuration_channel = EngineConfigurationChannel()
    env = UnityEnvironment(file_name=env_name,
                           side_channels=[engine_configuration_channel])
    env.reset()

    # 유니티 브레인 설정
    # 환경에서 이용 가능한 첫 번째 에이전트 이름을 받아서 behavior_name으로 설정
    behavior_name = list(env.behavior_specs.keys())[0]
    # behavuir_name에서 액션 공간, 관측 공간, 다른 에이전트의 속성같은 정보들을 가져와 spec에 저장
    spec = env.behavior_specs[behavior_name]
    # time scale로 유니티에서 환경이 돌아가는 속도를 조정
    engine_configuration_channel.set_configuration_parameters(time_scale=12.0)
    # 에이전트로부터 decision step과 terminal step을 받는다
    # decision step은 에이전트의 관측을 담고있다
    # terminal step은 에이전트의 액션과 보상을 담고있다
    dec, term = env.get_steps(behavior_name)

    # DDPGAgent 클래스를 agent로 정의
    agent = DDPGAgent()

    actor_losses, critic_losses, scores, episode, score = [], [], [], 0, 0
    for step in range(run_step + test_step):
        if step == run_step:
            if train_mode:
                agent.save_model()
            print("TEST START")
            train_mode = False
            engine_configuration_channel.set_configuration_parameters(time_scale=1.0)

        # 에이전트의 벡터 관측 정보를 받아 state 변수에 저장
        state = dec.obs[0]
        # 에이전트의 의사결정을 저장
        # 실제 에이전트의 행동을 설정
        action = agent.get_action(state, train_mode)
        action_tuple = ActionTuple()
        action_tuple.add_continuous(action)
        env.set_actions(behavior_name, action_tuple)
        
        env.step()

        # 환경으로부터 dec과 term 정보를 가져오고
        # 에피소드가 종료 됬는지 여부를 가리고
        # 보상을 reward 변수에 저장
        dec, term = env.get_steps(behavior_name)
        done = len(term.agent_id) > 0
        reward = term.reward if done else dec.reward
        next_state = term.obs[0] if done else dec.obs[0]
        score += reward[0]

        if train_mode:
            agent.append_sample(state[0], action[0], reward, next_state[0], [done])

        if train_mode and step > max(batch_size, train_start_step):
            # 학습 수행
            actor_loss, critic_loss = agent.train_model()
            actor_losses.append(actor_loss)
            critic_losses.append(critic_loss)

            # 타겟 네트워크 소프트 업데이트
            agent.soft_update_target()

        if done:
            episode += 1
            scores.append(score)
            score = 0

            # 게임 진행 상황 출력 및 텐서 보드에 보상과 손실함수 값 기록
            if episode % print_interval == 0:
                mean_score = np.mean(scores)
                mean_actor_loss = np.mean(actor_losses)
                mean_critic_loss = np.mean(critic_losses)
                agent.write_summray(mean_score, mean_actor_loss, mean_critic_loss, step)
                actor_losses, critic_losses, scores = [], [], []

                print(f"{episode} Episode / Step: {step} / Score: {mean_score:.2f} / " +\
                      f"Actor loss: {mean_actor_loss:.2f} / Critic loss: {mean_critic_loss:.4f}")

            # 네트워크 모델 저장
            if train_mode and episode % save_interval == 0:
                agent.save_model()

    env.close()

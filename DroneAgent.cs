using Unity.MLAgents;
using Unity.MLAgents.Actuators;
using Unity.MLAgents.Sensors;
using UnityEngine;
using PA_DronePack;

public class DroneAgent : Agent
{
    int i;
    private PA_DroneController dcoScript;
    public DroneSetting area;
    public GameObject goal;
    int goalIndex = 0;
    public Transform agentTrans;        // 에이전트 드론 transform
    public Transform goalTrans;
    private Rigidbody agent_Rigidbody;
    float preDist;
    int minIndex;

    public override void Initialize()
    {
        // 드론 PA_DroneController를 불러와 변수로 저장
        dcoScript = gameObject.GetComponent<PA_DroneController>();
        agentTrans = gameObject.transform;

        goalTrans = goal.transform;

        agent_Rigidbody = gameObject.GetComponent<Rigidbody>();

        Academy.Instance.AgentPreStep += WaitTimeInference;
    }

    // x,y,z 거리,속도,각속도의 9개 벡터
    public override void CollectObservations(VectorSensor sensor)
    {
        sensor.AddObservation(agentTrans.position - goalTrans.position);
        sensor.AddObservation(agent_Rigidbody.velocity);
        sensor.AddObservation(agent_Rigidbody.angularVelocity);
    }

    // Action에 따른 보상 설정
    public override void OnActionReceived(ActionBuffers actionBuffers)
    {
		AddReward(-0.01f);
        var actions = actionBuffers.ContinuousActions;

        // Clamp 범위 조절
        float moveX = Mathf.Clamp(actions[0], -1, 1f);
        float moveY = Mathf.Clamp(actions[1], -1, 1f);
        float moveZ = Mathf.Clamp(actions[2], -1, 1f);

        dcoScript.DriveInput(moveX);    // 앞뒤
        dcoScript.StrafeInput(moveY);   // 좌우
        dcoScript.LiftInput(moveZ);     // 위아래

        // set Reward Parameter for drone agent
        // 거리(distance)  = 목표지점 벡터 - 에이전트 위치 벡터
        float distance = Vector3.Magnitude(goalTrans.position - agentTrans.position);
        if(distance <= 1f)
        {
            SetReward(10f);
        }
        else if(distance > 90f)
        {
			SetReward(-100f);
            EndEpisode();
        }
        else
        {
            float reward = preDist - distance;
			AddReward(reward);
            preDist = distance;
        }

    }

    // episode가 시작될때 호출되며 환경 초기화, 목표 탐색, 목표 달성 후 드론 pos초기화
    public override void OnEpisodeBegin()
    {
        // 환경 설정 스크립트로부터 환경 로딩
        area.AreaSetting();     
        // 목표점 중 Drone으로부터 가장 가까운 목표점 탐색 후 Goal로 설정
        goal = area.SearchGoal();   // 수정 필요
        goalTrans = goal.transform;
        // 가장 가까운 거리를 preDist 변수에 저장 후 학습 시작
        preDist = Vector3.Magnitude(goalTrans.position - agentTrans.position);
    }

    // User Input
    public override void Heuristic(in ActionBuffers actionsOut)
    {
        var continuousActionsOut = actionsOut.ContinuousActions;

        continuousActionsOut[0] = Input.GetAxis("Vertical");
        continuousActionsOut[1] = Input.GetAxis("Horizontal");
        continuousActionsOut[2] = Input.GetAxis("Mouse ScrollWheel");
    }

    public float DecisionWaitingTime = 5f;
    float m_currentTime = 0f;

    public void WaitTimeInference(int action)
    {
        if(Academy.Instance.IsCommunicatorOn)
        {
            RequestDecision();
        }
        else
        {
            if(m_currentTime >= DecisionWaitingTime)
            {
                m_currentTime = 0f;
                RequestDecision();
            }
            else
            {
                m_currentTime += Time.fixedDeltaTime;
            }
        }
    }
}

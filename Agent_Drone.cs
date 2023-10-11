using Unity.MLAgents;
using Unity.MLAgents.Actuators;
using Unity.MLAgents.Sensors;
using UnityEngine;
using System;
using PA_DronePack;
using UnityEngine.UI;

public class DroneAgent : Agent
{
    private PA_DroneController dcoScript;
    // 오브젝트 변수
    public GameObject Drone;
    private Rigidbody DroneAgent_Rigidbody;
    public GameObject goal; 
    public int numOfGoals = 47;
    public GameObject[] Goals = new GameObject[47];
    public GameObject[] Ranges = new GameObject[47];
    public GameObject targetRange;      // 목표점의 반경 객체
    private Material matDefault;
    private Material matDetection;
    // 에이전트, 목표점, 목표점 반경 위치 변수 및 배열 초기화
    private Transform agentTrans;
    private Transform DroneTrans;
    private Transform goalTrans;
    private Transform targetRangeTrans;  // 목표점의 위치 선언
    private Transform[] GoalsTrans = new Transform[47];
    private Transform[] rangesTrans = new Transform[47];
    private Vector3 droneInitPos;               // DroneTrans 형 position을 저장하는 Vector3 형 droneInitPos
    private Quaternion droneInitRot;
    // 3D 오브젝트 크기, 위치 변수 선언 & 초기화
    int posx = 0;   // x값 레퍼런스
    int posy = 20;  // y값 레퍼런스
    int posz = 0;   // z값 레퍼런스
    float cylinderHeight = 0.5f;
    float cylinderRadius = 40f;
    int cylY = 0;

    float goalDiff;
    float[] goalDiffArray = new float[47];     // 거리 비교 goalDiff가 저장될 배열  
    float preDist;
    
    private Text goalNum;
    private Text statusText;
    bool hit = false;
    bool first = true;

    void Start(){
        Debug.Log("Start함수 실행");
        DroneTrans = Drone.transform;
        droneInitPos = DroneTrans.position; // Transform 형의 position을 저장하는 Vector3 형
        droneInitRot = DroneTrans.rotation;

        DroneAgent_Rigidbody = Drone.GetComponent<Rigidbody>();

        matDefault = Resources.Load("Materials/Default", typeof(Material)) as Material;
        matDetection = Resources.Load("Materials/Detection", typeof(Material)) as Material;

        goalNum = GameObject.Find("Text").GetComponent<Text>();
        statusText = GameObject.Find("Status").GetComponent<Text>();

        // 게임이 실행되면 목표점을 저장하고 해당 목표점들의 반경 표시 객체를 생성
        for(int i = 0; i<numOfGoals;i++){
            Goals[i] = GameObject.Find((i+1).ToString());
            GoalsTrans[i] = Goals[i].transform;

            GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            cylinder.transform.localScale = new Vector3(cylinderRadius,cylinderHeight,cylinderRadius);
            cylinder.transform.position = new Vector3(GoalsTrans[i].position.x, 0, GoalsTrans[i].position.z);
            cylinder.GetComponent<Renderer>().material = matDefault;
            Ranges[i] = cylinder;
            rangesTrans[i] = cylinder.transform;
        }
    }

    // 드론 에이전트의 초기 상태 정의
    public void DroneInit(){
        DroneAgent_Rigidbody.velocity = Vector3.zero;
        DroneAgent_Rigidbody.angularVelocity = Vector3.zero;
        DroneTrans.position = droneInitPos;
        DroneTrans.rotation = droneInitRot;
    }

    // 최근접 목표점 탐색 함수
    public (GameObject goal,GameObject targetRange) SearchGoal(){
        float closestDistanceSqr = Mathf.Infinity;
        int j = 0;
        for(int i = 0; i<numOfGoals;i++){
            Vector3 directionToTarget = (GoalsTrans[i].position - DroneTrans.position);
            float dSqrToTarget = directionToTarget.sqrMagnitude;
            if(dSqrToTarget < closestDistanceSqr){
                closestDistanceSqr = dSqrToTarget;
                goal = Goals[i];
                targetRange = Ranges[i];
                j = i;
            }
            // goalDiffArray 초기화하여 거리 정보 새로 업데이트 가능하도록 수정
            goalDiffArray[i] = float.NaN;
        }
        Debug.Log("SEARCHGOAL FUNC: Number "+(j+1)+" Goal is now new Goal");
        return (goal,targetRange);
    }

    // 목표점의 반경 targetRange의 Material을 변경
    public void ChangeColor(GameObject targetRange, Material matDetection){
        targetRange.GetComponent<Renderer>().material = matDetection;
    }

    // 목표점을 찾은 후 드론의 초기 위치를 해당 목표점으로 업데이트
    public void MoveDronePos(){
        droneInitPos = goalTrans.position;
    }

    // 도달한 목표점과 영역이 겹치는 다른 목표점 삭제 
    public void RemoveGoals(){
        for(int i = 0; i<numOfGoals;i++){
            goalDiff = Vector3.Magnitude(goalTrans.position - GoalsTrans[i].position);
            goalDiffArray[i] = goalDiff;
            Debug.Log("Goal< " + (i+1) + ">'s goalDiff is< " + goalDiff +">");
            // 반경이 서로 겹치는 범위 내에 존재하며 배열내 같은 목표점끼리 비교하는것이 아니라면 목표점을 삭제
            if(goalDiff < 40 && goalDiff != 0){
                GoalsTrans[i].position = new Vector3(160,20,160);
                rangesTrans[i].position = new Vector3(160,1,160);
                Debug.Log("Number of<" + (i+1) + "> Goal moved");
            }
        }
        goalTrans.position = new Vector3(160,20,160);   // 마지막으로 골도 제거(이동)
    }

    public override void Initialize()
    {
        dcoScript = gameObject.GetComponent<PA_DroneController>();
        agentTrans = gameObject.transform;
        Academy.Instance.AgentPreStep += WaitTimeInference;
    }

    public override void OnEpisodeBegin()
    {
        Debug.Log("episode beginning");
        // 첫번째로 시작되는 에피소드에서 목표점을 탐색
        if(first == true){
            var (goal,targetRange) = SearchGoal();
            first = false;
            statusText.text = "첫 번째 에피소드 실행";
        }
        // 에피소드가 두번째부터이며 목표점에 전에 도달하였다면 다시 새롭게 목표점을 탐색
        else if(first == false && hit == true){
            var (goal,targetRange) = SearchGoal();
            statusText.text = "새 목표점 탐색 실행";
        }
        // 그렇지 않으면(에피소드가 두번째부터이며 목표점을 몾 찾았다면) pass
        else if(first == false && hit == false){
            statusText.text = "목표점 포착 실패";
        }
        Debug.Log("Goal: "+goal+"targetRange: "+targetRange);
        goalTrans = goal.transform;
        targetRangeTrans = targetRange.transform;
        DroneInit();
        preDist = Vector3.Magnitude(goalTrans.position - agentTrans.position);
    }

    public override void OnActionReceived(ActionBuffers actionBuffers)
    {
		AddReward(-0.01f);
        var actions = actionBuffers.ContinuousActions;
        float moveX = Mathf.Clamp(actions[0], -1, 1f);
        float moveY = Mathf.Clamp(actions[1], -1, 1f);
        float moveZ = Mathf.Clamp(actions[2], -1, 1f);
        dcoScript.DriveInput(moveX);
        dcoScript.StrafeInput(moveY);
        dcoScript.LiftInput(moveZ);

        float distance = Vector3.Magnitude(goalTrans.position - agentTrans.position);

        if(distance < 1f){
            SetReward(2f);     // 2f
            ChangeColor(targetRange,matDetection);
            MoveDronePos();     // 목표점 도달 시 드론 초기 위치를 이동
            RemoveGoals();      // 목표점 근처 겹치는 반경의 목표점들을 제거
            EndEpisode();
            hit = true;
            
        }
        else if(distance > 65f){
			SetReward(-2f);   // -2f
            EndEpisode();
            hit = false;
            
        }
        else{
            float reward = preDist - distance;
			AddReward(reward);
            preDist = distance;  
        }
        goalNum.text = "number of goal is: "+ goal;
    }

    public override void CollectObservations(VectorSensor sensor)
    {
        sensor.AddObservation(agentTrans.position - goalTrans.position);
        sensor.AddObservation(DroneAgent_Rigidbody.velocity);
        sensor.AddObservation(DroneAgent_Rigidbody.angularVelocity);
    }

    public override void Heuristic(in ActionBuffers actionsOut)
    {
        var continuousActionsOut = actionsOut.ContinuousActions;

        continuousActionsOut[0] = Input.GetAxis("Vertical");
        continuousActionsOut[1] = Input.GetAxis("Horizontal");
        continuousActionsOut[2] = Input.GetAxis("Mouse ScrollWheel");
    }

    float DecisionWaitingTime = 0.01f;
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

    // 목표점의 위치를 랜덤하게 생성(학습에 용이하도록 랜덤성을 부여)
    // public void GoalTransSet(){
    //     goalTrans.position = new Vector3(UnityEngine.Random.Range(posx+(-10f), posx+(10f)), posy, UnityEngine.Random.Range(posz+(-10f), posz+(10f)));
    //     targetRangeTrans.position = new Vector3(goalTrans.position.x, cylY, goalTrans.position.z);
    // }
}
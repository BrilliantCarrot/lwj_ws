using Unity.MLAgents;
using Unity.MLAgents.Actuators;
using Unity.MLAgents.Sensors;
using UnityEngine;
using System;
using PA_DronePack;

public class DroneAgent : Agent
{
    // Stopwatch watch = new Stopwatch();
    // float timePassed = 0f;
    private PA_DroneController dcoScript;
    // 오브젝트 변수
    public GameObject Drone;
    public DroneSetting area;           // AreaSetting에서 드론의 초기 상태도 초기화
    public GameObject goal;
    public int numOfGoals = 10;
    public GameObject[] Goals = new GameObject[10];
    public GameObject[] Ranges = new GameObject[10];
    public GameObject targetRange;      // 목표점의 반경 객체
    // private Material[] mat = new Material[4];
    private Material matDefault;
    private Material matDetection;
    // public GameObject Range;
    // 에이전트, 목표점, 목표점 반경 위치 변수 및 배열 초기화
    private Transform agentTrans;
    private Transform DroneTrans;
    public Transform goalTrans;
    public Transform targetRangeTrans;  // 목표점의 위치 선언
    Vector3 droneInitPos;               // 드론위치 설정 Vector3 변수
    Quaternion droneInitRot;
    public Transform[] GoalsTrans = new Transform[10];
    public Transform[] rangesTrans = new Transform[10];
    // 크기, 위치 변수 선언 & 초기화
    int posx = 0;
    int posy = 20;
    int posz = 0;
    float cylinderHeight = 0.5f;
    float cylinderRadius = 40f;
    int cylY = 0;

    float goalDiff;
    private float[] goalDiffArray = new float[70];     // 거리 비교 goalDiff가 저장될 배열  
    float preDist;
    private Rigidbody DroneAgent_Rigidbody;
    float maxNum;
    bool hit = false;

    void Start(){
        DroneTrans = Drone.transform;
        droneInitPos = DroneTrans.position; // Transform 형의 position을 저장하는 Vector3 형
        droneInitRot = DroneTrans.rotation;
        DroneAgent_Rigidbody = Drone.GetComponent<Rigidbody>();
        // mat = Resources.LoadAll<Material>("Materials");
        matDefault = Resources.Load("Materials/Default", typeof(Material)) as Material;
        matDetection = Resources.Load("Materials/Detection", typeof(Material)) as Material;
        // 게임이 실행되면 목표점을 저장하고 해당 목표점들의 반경 표시 객체를 생성
        for(int i = 0; i<numOfGoals;i++){
            Goals[i] = GameObject.Find((i+1).ToString());
            GoalsTrans[i] = Goals[i].transform;

            // 반경을 나타내는 Cylinder형 Range의 배열을 초기화
            GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            cylinder.transform.localScale = new Vector3(cylinderRadius,cylinderHeight,cylinderRadius);
            cylinder.transform.position = new Vector3(GoalsTrans[i].position.x, 0, GoalsTrans[i].position.z);
            cylinder.GetComponent<Renderer>().material = matDefault;
            Ranges[i] = cylinder;
            rangesTrans[i] = cylinder.transform;
            // Debug.Log((i+1)+"번째 객체 찾음");
        }
        // var (goal,targetRange) = SearchGoal();
        // goalTrans = goal.transform;
        // targetRangeTrans = targetRange.transform;
    }

    // public GameObject SearchGoal(){
    //     // target = null;
    //     float closestDistanceSqr = Mathf.Infinity;

    //     for(int i = 0; i<numOfGoals;i++){
    //         Vector3 directionToTarget = (GoalsTrans[i].position - DroneTrans.position);
    //         float dSqrToTarget = directionToTarget.sqrMagnitude;

    //         if(dSqrToTarget < closestDistanceSqr){
    //             closestDistanceSqr = dSqrToTarget;
    //             goal = Goals[i];
    //         }
    //     }
    //     return goal;
    // }

    // 최근접 목표점 탐색 함수
    public (GameObject goal,GameObject targetRange) SearchGoal(){
        float closestDistanceSqr = Mathf.Infinity;

        for(int i = 0; i<numOfGoals;i++){
            if(hit == false){Vector3 directionToTarget = (GoalsTrans[i].position - DroneTrans.position);
            float dSqrToTarget = directionToTarget.sqrMagnitude;
                if(dSqrToTarget < closestDistanceSqr){
                    closestDistanceSqr = dSqrToTarget;
                    goal = Goals[i];
                    targetRange = Ranges[i];
            }
            }
            else if(hit == true){
                Vector3 directionToTarget = (GoalsTrans[i].position - droneInitPos);
                float dSqrToTarget = directionToTarget.sqrMagnitude;
                if(dSqrToTarget < closestDistanceSqr){
                    closestDistanceSqr = dSqrToTarget;
                    goal = Goals[i];
                    targetRange = Ranges[i];
            }
            }
            // float dSqrToTarget = directionToTarget.sqrMagnitude;

            // if(dSqrToTarget < closestDistanceSqr){
            //     closestDistanceSqr = dSqrToTarget;
            //     goal = Goals[i];
            //     targetRange = Ranges[i];
            // }
        }
        return (goal,targetRange);
    }

    // 목표점의 반경 targetRange의 Material을 변경
    public void ChangeColor(GameObject targetRange, Material matDetection){
        // Range.GetComponent<MeshRenderer>().material = mat[1];
        targetRange.GetComponent<Renderer>().material = matDetection;
    }

    // 목표점의 위치를 랜덤하게 생성(학습에 용이하도록 랜덤성을 부여)
    public void GoalTransSet(){
        goalTrans.position = new Vector3(UnityEngine.Random.Range(posx+(-10f), posx+(10f)), posy, UnityEngine.Random.Range(posz+(-10f), posz+(10f)));
        targetRangeTrans.position = new Vector3(goalTrans.position.x, cylY, goalTrans.position.z);
    }

    public void MoveDronePos(){
        // DroneTrans 형 position을 저장하는 Vector3 형 droneInitPos
        // area.droneInitPos = DroneTrans.position;
        droneInitPos = goalTrans.position;
    }

    // 새 에피소드 시작 후 목표점 위치는 확인 필요
    // public void GoalTransReset(){
    //     Array.Clear(Goals,0,Goals.Length);
    //     Array.Clear(GoalsTrans,0,GoalsTrans.Length);
    //     for(int i = 0; i<numOfGoals;i++){
    //         Goals[i] = GameObject.Find((i+1).ToString());
    //         GoalsTrans[i] = Goals[i].transform;
    //         GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
    //         cylinder.transform.localScale = new Vector3(cylinderRadius,cylinderHeight,cylinderRadius);
    //         cylinder.transform.position = new Vector3(GoalsTrans[i].position.x, 0, GoalsTrans[i].position.z);
    //         cylinder.GetComponent<Renderer>().material = matDefault;
    //         Ranges[i] = cylinder;
    //         rangesTrans[i] = cylinder.transform;
    //     }
    // }

    // 도달한 목표점과 영역이 겹치는 다른 목표점 삭제 & 새 목표점 확인
    public void RemoveGoals(){
        // 목표점 삭제
        for(int i = 0; i<numOfGoals;i++){
            goalDiff = Vector3.Magnitude(goalTrans.position - GoalsTrans[i].position);
            goalDiffArray[i] = goalDiff;
            Debug.Log("Goal " + (i+1) + "'s goalDiff is: " + goalDiff);
            // 반경이 서로 겹치는 범위 내에 존재하며 같은 배열 내의 목표점을 비교하는것이 아니라면
            // if(goalDiff < 40 && goalTrans.position != GoalsTrans[i].position)
            if(goalDiff < 30 && goalDiff != 0){
                // Destroy(Goals[i]);
                // Goals[i] = null;
                // Destroy(GoalsTrans[i]);
                // GoalsTrans[i] = null;
                // 겹치는 반경 내 목표점을 제거
                GoalsTrans[i].position = new Vector3(160,20,160);
                rangesTrans[i].position = new Vector3(160,1,160);
                Debug.Log("Number of " + (i+1) + "Goal moved");
            }
        }
        // // 새 목표점 확인
        // for(int i = 0; i<numOfGoals;i++){
        //     maxNum = 5000;
        //     if(goalDiffArray[i] <= maxNum && goalDiffArray[i] != 0){
        //         maxNum = goalDiffArray[i];
        //         goal = Goals[i];
        //         targetRange = Ranges[i];
        //     }
        // }
        goalTrans.position = new Vector3(160,20,160);   // 마지막으로 골도 제거(이동)
        
    }

    public void NextGoal(){
        // 새 목표점 확인
        int j = 0;
        int minIndex = 0;
        for(j = 0; j<numOfGoals;j++){
            maxNum = 5000;
            if(goalDiffArray[j] <= maxNum && goalDiffArray[j] != 0){
                maxNum = goalDiffArray[j];
                goal = Goals[j];
                targetRange = Ranges[j];
                minIndex = j;
            }
        }
        Debug.Log("Number "+minIndex+" Goal is now new Goal");
    }

    public override void Initialize()
    {
        dcoScript = gameObject.GetComponent<PA_DroneController>();
        agentTrans = gameObject.transform;
        // goal = SearchGoal();
        // goalTrans = goal.transform;
        // goal = area.Goal;
        // goalTrans = area.Goal.transform;
        // goalTrans = goal.transform;
        // DroneAgent_Rigidbody = gameObject.GetComponent<Rigidbody>();
        Academy.Instance.AgentPreStep += WaitTimeInference;
    }

    public override void OnEpisodeBegin()
    {
        
            var (goal,targetRange) = SearchGoal();
        
              // 에피소드 시작시마다 가장 가까운 목표점 탐색
        // goal.GetComponent<Renderer>().material = matDetection;
        goalTrans = goal.transform;
        targetRangeTrans = targetRange.transform;
        // watch.Start();
        // timePassed = 0f;
        // timePassed += Time.deltaTime;
        DroneInit();
        if(hit == false){
            Debug.Log("GoalTransSet function executed");
            GoalTransSet();
        }
        
        // goal = area.Goal;
        // goalTrans = goal.transform;
        preDist = Vector3.Magnitude(goalTrans.position - agentTrans.position);
    }

    public override void CollectObservations(VectorSensor sensor)
    {
        sensor.AddObservation(agentTrans.position - goalTrans.position);
        sensor.AddObservation(DroneAgent_Rigidbody.velocity);
        sensor.AddObservation(DroneAgent_Rigidbody.angularVelocity);
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

        // 1 2 20 -1
        if(distance < 1f){
            SetReward(2f);
            ChangeColor(targetRange,matDetection);
            hit = true;
            MoveDronePos();
            // Debug.Log("Removing Goal");
            RemoveGoals();
            NextGoal();
            // Debug.Log("new goal: "+goal+", new targetRange: "+ targetRange);
            // goalTrans.position = new Vector3(160,20,160);
            // GoalTransReset();
            EndEpisode();
        }
        // distance 추가
        // else if (distance < 2f){
        //     AddReward(50f);
        // }
        // else if (distance <= 1.5f){
        //     move = true;
        // }
        else if(distance > 20f){
            // if(hit != true){
            //     area.droneInitPos = new Vector3(0, 20, 0);
            // }
            // hit = false;
			SetReward(-2f);
            EndEpisode();
        }
        // else if(preDist - distance == 0f && move == true){
        //     SetReward(-1f);
        //     EndEpisode();
        // }
        // if(timePassed >= 5f){
        //     // watch.Stop();
        //     // timePassed = 0f;
        //     EndEpisode();
        // }
        else{
            float reward = preDist - distance;
			// if (reward > 0f)
			// 	reward = reward * 1.2f;
			AddReward(reward);
            preDist = distance;  
        }
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

    public void DroneInit(){
        DroneAgent_Rigidbody.velocity = Vector3.zero;
        DroneAgent_Rigidbody.angularVelocity = Vector3.zero;
        DroneTrans.position = droneInitPos;
        DroneTrans.rotation = droneInitRot;
    }
}
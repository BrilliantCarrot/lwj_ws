using Unity.MLAgents;
using Unity.MLAgents.Actuators;
using Unity.MLAgents.Sensors;
using UnityEngine;
// using System.Diagnostics;
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
    public int numOfGoals = 7;
    public GameObject[] Goals = new GameObject[7];
    public GameObject[] Ranges = new GameObject[7];
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
    public Transform[] GoalsTrans = new Transform[7];
    public Transform[] rangesTrans = new Transform[7];
    // 크기, 위치 변수 선언 & 초기화
    int posx = 0;
    int posy = 20;
    int posz = 0;
    
    float cylinderHeight = 0.5f;      // 2f
    float cylinderRadius = 50f;
    int cylY = 0;

    float preDist;
    private Rigidbody agent_Rigidbody;
    bool hit = false;

    void Start(){
        DroneTrans = Drone.transform;
        // mat = Resources.LoadAll<Material>("Materials");
        matDefault = Resources.Load("Materials/Default", typeof(Material)) as Material;
        matDetection = Resources.Load("Materials/Detection", typeof(Material)) as Material;
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
                Vector3 directionToTarget = (GoalsTrans[i].position - area.droneInitPos);
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

    // Range 한개 객체 Material 변경
    public void ChangeColor(GameObject targetRange, Material matDetection){
        // Range.GetComponent<MeshRenderer>().material = mat[1];
        targetRange.GetComponent<Renderer>().material = matDetection;
    }

    // 목표점의 위치를 랜덤하게 생성(학습에 용이하도록 랜덤성을 부여)
    public void GoalTransSet(){
        goalTrans.position = new Vector3(Random.Range(posx+(-10f), posx+(10f)), posy, Random.Range(posz+(-10f), posz+(10f)));
        targetRangeTrans.position = new Vector3(goalTrans.position.x, cylY, goalTrans.position.z);
    }

    public void MoveDronePos(){
        // DroneTrans 형 position을 저장하는 Vector3 형 droneInitPos
        // area.droneInitPos = DroneTrans.position;
        area.droneInitPos = goalTrans.position;
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

        agent_Rigidbody = gameObject.GetComponent<Rigidbody>();
        Academy.Instance.AgentPreStep += WaitTimeInference;
    }

    public override void OnEpisodeBegin()
    {
        var (goal,targetRange) = SearchGoal();      // 에피소드 시작시마다 가장 가까운 목표점 탐색
        goalTrans = goal.transform;
        targetRangeTrans = targetRange.transform;
        // watch.Start();
        // timePassed = 0f;
        // timePassed += Time.deltaTime;
        area.AreaSetting();
        GoalTransSet();
        // goal = area.Goal;
        // goalTrans = goal.transform;
        preDist = Vector3.Magnitude(goalTrans.position - agentTrans.position);
    }

    public override void CollectObservations(VectorSensor sensor)
    {
        sensor.AddObservation(agentTrans.position - goalTrans.position);
        sensor.AddObservation(agent_Rigidbody.velocity);
        sensor.AddObservation(agent_Rigidbody.angularVelocity);
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
            hit = false;
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
}
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
    public GameObject Drone;
    public DroneSetting area;
    public GameObject goal;
    public int numOfGoals = 7;
    public GameObject[] Goals = new GameObject[7];
    public GameObject[] Ranges = new GameObject[7];
    // private GameObject target;
    private Material[] mat = new Material[4];
    public GameObject Range;
    float preDist;
    private Transform agentTrans;
    public Transform goalTrans;
    public Transform[] GoalsTrans = new Transform[7];
    private Transform DroneTrans;
    
    int posx = 0;
    int posy = 20;
    int posz = 0;
    bool move = false;
    private Rigidbody agent_Rigidbody;

    void Start(){
        DroneTrans = Drone.transform;
        for(int i = 0; i<numOfGoals;i++){
            Goals[i] = GameObject.Find((i+1).ToString());
            GoalsTrans[i] = Goals[i].transform;
            // 
        }
        goal = SearchGoal();
        goalTrans = goal.transform;
        // droneInitPos = DroneTrans.position;
        // droneInitRot = DroneTrans.rotation;
    }

    public void ChangeColor(){
        Range.GetComponent<MeshRenderer>().material = mat[1];
    }

    public GameObject SearchGoal(){
        // target = null;
        float closestDistanceSqr = Mathf.Infinity;

        for(int i = 0; i<numOfGoals;i++){
            Vector3 directionToTarget = (GoalsTrans[i].position - DroneTrans.position);
            float dSqrToTarget = directionToTarget.sqrMagnitude;

            if(dSqrToTarget < closestDistanceSqr){
                closestDistanceSqr = dSqrToTarget;
                goal = Goals[i];
            }
        }
        return goal;
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
            ChangeColor();
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
    // Random.Range(posx+(-5f), posx+(5f))
    public void GoalTransSet(){
        goalTrans.position = new Vector3(Random.Range(posx+(-10f), posx+(10f)), 20, Random.Range(posx+(-10f), posz+(10f)));
    }
}
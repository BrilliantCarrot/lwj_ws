using UnityEngine;
using Unity.MLAgents;

public class DroneSetting : MonoBehaviour
{
    // public DroneAgent agent;
    public GameObject DroneAgent;   //DroneAgent에서는 Drone
    private GameObject Goal;
    // public int numOfGoals = 7;
    // public GameObject[] Goals = new GameObject[7];
    // public GameObject target;
    Vector3 areaInitPos;
    public Vector3 droneInitPos;
    Quaternion droneInitRot;

    EnvironmentParameters m_ResetParams;

    private Transform AreaTrans;
    public Transform DroneTrans;
    private Transform GoalTrans;
    // public Transform[] GoalsTrans = new Transform[7];
    private Rigidbody DroneAgent_Rigidbody;



    void Start()
    {
        // for(int i = 0; i<numOfGoals;i++){
        //     Goals[i] = GameObject.Find((i+1).ToString());
        //     GoalsTrans[i] = Goals[i].transform;
        // }
        Debug.Log(m_ResetParams);

        AreaTrans = gameObject.transform;
        DroneTrans = DroneAgent.transform;
        // GoalTrans = Goal.transform;
        // Goal = SearchGoal();
        // GoalTrans = Goal.transform;

        areaInitPos = AreaTrans.position;
        droneInitPos = DroneTrans.position; // Transform 형의 position을 저장하는 Vector3 형
        droneInitRot = DroneTrans.rotation;

        DroneAgent_Rigidbody = DroneAgent.GetComponent<Rigidbody>();
    }

    public void AreaSetting()
    {
        DroneAgent_Rigidbody.velocity = Vector3.zero;
        DroneAgent_Rigidbody.angularVelocity = Vector3.zero;

        DroneTrans.position = droneInitPos;
        DroneTrans.rotation = droneInitRot;

        // Goal = SearchGoal();
        // GoalTrans = Goal.transform;
        // GoalTrans.position = areaInitPos + new Vector3(Random.Range(posx+(-5f), posx+(5f)), 20, 0);
        // GoalTrans.position = areaInitPos + new Vector3(Random.Range(-5f, 5f), Random.Range(-5f, 5f), Random.Range(-5f, 5f));
    }
    //     public GameObject SearchGoal(){
    //     target = null;
    //     float closestDistanceSqr = Mathf.Infinity;

    //     for(int i = 0; i<numOfGoals;i++){
    //         Vector3 directionToTarget = (GoalsTrans[i].position - DroneTrans.position);
    //         float dSqrToTarget = directionToTarget.sqrMagnitude;

    //         if(dSqrToTarget < closestDistanceSqr){
    //             closestDistanceSqr = dSqrToTarget;
    //             target = Goals[i];
    //         }
    //     }
    //     return target;
    // }
}

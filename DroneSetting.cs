using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.MLAgents;
using System;
using Unity.Mathematics;



public class DroneSetting : MonoBehaviour
{
    int i;
    int numOfGoals = 6;            // 타겟 Goal(소노부이)들의 갯수
    public Material Land_Material;
    float planeSize = 12.5f;        // 바다 표면
    float cylinderHeight = 2f;      
    float cylinderRadius = 25f;     // 탐지반경
    int sphereRadius = 4;           // 소노부이 크기
    float posY = 0.5f;              // 0.5f
    public GameObject DroneAgent;   // 드론 에이전트 
    public GameObject[] Goal = new GameObject[6];       // 타겟 Goal들이 저장될 배열

    Vector3 areaInitPos;
    // 에피소드 시작 시 드론을 초기 상태로 리셋
    Vector3 droneInitPos;
    Quaternion droneInitRot;
    Vector3 droneNextPos;               // 에피소드 종료 후(소노부이 투하점을 찾았을 시)드론을 해당 위치로 이동
    EnvironmentParameters m_ResetParams;        // 학습에 필요한 인자들을 관리
    private Transform AreaTrans;        // Area 오브젝트의 위치, 회전 정보
    private Transform DroneTrans;
    private Transform[] GoalTrans;      // 생성된 목표점들의 위치를 저장할 Transform 배열 선언
    // private Transform GoalTrans;
    // private Transform Goal2Trans;
    // private Transform Goal3Trans;
    // private Transform Goal4Trans;
    // private Transform Goal5Trans;
    // private Transform Goal6Trans;

    private Rigidbody DroneAgent_Rigidbody;

    // 70개의 골 위치가 포함될 리스트 작성
    // <GameObject> Goal = new List<GameObject>();

    // float randomX = UnityEngine.Random.Range(-50f, 50f);      // 500f
    // float randomZ = UnityEngine.Random.Range(-50f, 50f);      // 500f

    void Start()
    {
        // Goal.transform을 저장할 배열 초기화
        // GoalTrans = new Transform[numOfGoals];
        for (i = 0; i<numOfGoals; i++){
            // // 소노부이 반경
            // GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            // cylinder.transform.localScale = new Vector3(cylinderRadius,cylinderHeight,cylinderRadius);
		    // cylinder.transform.position = new Vector3(randomX, posY, randomZ);

            // // 타겟(골)
            // GameObject Goal = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            // Goal.transform.localScale = new Vector3(sphereRadius,sphereRadius,sphereRadius);
		    // Goal.transform.position = new Vector3(randomX, posY+75, randomZ);

            // Goal[i] = GameObject.FindGameObjectWithTag("Goal");
            Goal[i] = GameObject.Find((i+1).ToString());

            // 머티리얼 적용, 수정 필요
            // Renderer Goal_Renderer = Goal.GetComponent<Renderer>();
            // if (Land_Material != null){
            //     // Renderer renderer = GetComponent<Renderer>();
            //     Goal_Renderer.material = Land_Material;
            // }

            // goalList.Add(Goal);
            // GoalTrans[i] = Goal.transform;
        }
        // Console.WriteLine("생성된 goalList들: {0}",Goal.Count );
        // Console.ReadKey();

        Debug.Log(m_ResetParams);

        AreaTrans = gameObject.transform;
        DroneTrans = DroneAgent.transform;
        // GoalTrans = Goal.transform;
        // Goal2Trans = Goal2.transform;
        // Goal3Trans = Goal3.transform;
        // Goal4Trans = Goal4.transform;
        // Goal5Trans = Goal5.transform;
        // Goal6Trans = Goal6.transform;

        areaInitPos = AreaTrans.position;       // 위치 정보가 저장된 position을 Vector3로 가져온다
        droneInitPos = DroneTrans.position;
        droneInitRot = DroneTrans.rotation;

        // 에피소드 종료 후 드론의 위치
        // droneNextPos = 1f;

        DroneAgent_Rigidbody = DroneAgent.GetComponent<Rigidbody>();
    }

    public void AreaSetting()
    {
        DroneAgent_Rigidbody.velocity = Vector3.zero;
        DroneAgent_Rigidbody.angularVelocity = Vector3.zero;

        DroneTrans.position = droneInitPos;
        DroneTrans.rotation = droneInitRot;

        // GoalTrans.position = areaInitPos + new Vector3(UnityEngine.Random.Range(-5f, 5f), 5, UnityEngine.Random.Range(-5f, 5f));
        // Goal2Trans.position = areaInitPos + new Vector3(UnityEngine.Random.Range(-5f, 5f), 5, UnityEngine.Random.Range(-5f, 5f));
        // Goal3Trans.position = areaInitPos + new Vector3(UnityEngine.Random.Range(-5f, 5f), 5, UnityEngine.Random.Range(-5f, 5f));
        // Goal4Trans.position = areaInitPos + new Vector3(UnityEngine.Random.Range(-5f, 5f), 5, UnityEngine.Random.Range(-5f, 5f));
        // Goal5Trans.position = areaInitPos + new Vector3(UnityEngine.Random.Range(-5f, 5f), 5, UnityEngine.Random.Range(-5f, 5f));
        // Goal6Trans.position = areaInitPos + new Vector3(UnityEngine.Random.Range(-5f, 5f), 5, UnityEngine.Random.Range(-5f, 5f));
    }

    // public void SearchGoal(){
    //     for(int i = 0; i<numOfGoals;i++){
    //         Math.Sqrt(Math.Pow(GoalTrans[i].position.x,2) + Math.Pow(GoalTrans[i].position.y,2));
    //     }
    // }

    public void MoveDronePos(){
        
    }
}

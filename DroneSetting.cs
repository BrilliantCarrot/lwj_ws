using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.MLAgents;
using System;
using Unity.Mathematics;



public class DroneSetting : MonoBehaviour
{
    int i;
    int numOfGoals = 10;    // 만들 Goal(소노부이)들의 갯수
    public Material Land_Material;
    float planeSize = 12.5f;         // 125f
    float cylinderHeight = 2f;      // 2f
    float cylinderRadius = 25f;    // 250f
    int sphereRadius = 4;           // 8
    float posY = 0.5f;              // 0.5f
    // Public은 Inspector 상으로 표시
    public GameObject DroneAgent;
    // 원래 Goal
    // public GameObject[] Goal;
    public GameObject Goal;
    public GameObject Goal2;

    Vector3 areaInitPos;
    // 에피소드 시작 시 드론을 초기 상태로 리셋
    Vector3 droneInitPos;
    Quaternion droneInitRot;
    // 에피소드 종료 후(소노부이 투하점을 찾았을 시)드론을 해당 위치로 이동
    Vector3 droneNextPos;

    EnvironmentParameters m_ResetParams;        // 학습에 필요한 인자들을 관리
    private Transform AreaTrans;        // Area 오브젝트의 위치, 회전 정보
    private Transform DroneTrans;
    // 생성된 목표점들의 위치를 저장할 Transform 배열 선언
    // private Transform[] GoalTrans;
    private Transform GoalTrans;
    private Transform Goal2Trans;

    private Rigidbody DroneAgent_Rigidbody;

    // 70개의 골 위치가 포함될 리스트 작성
    // List<GameObject> goalList = new List<GameObject>();

    void Start()
    {
        // Goal.transform을 저장할 배열 초기화
        // GoalTrans = new Transform[numOfGoals];
        // for (i = 0; i<numOfGoals; i++){
        //     float randomX = UnityEngine.Random.Range(-50f, 50f);      // 500f
        //     float randomZ = UnityEngine.Random.Range(-50f, 50f);      // 500f

        //     // 바다
        //     GameObject plane = GameObject.CreatePrimitive(PrimitiveType.Plane);
        //     plane.transform.localScale = new Vector3(planeSize, 1f, planeSize);
        //     plane.transform.position = new Vector3(0f, 0f, 0f);

        //     // 소노부이 반경
        //     GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        //     cylinder.transform.localScale = new Vector3(cylinderRadius,cylinderHeight,cylinderRadius);
		//     cylinder.transform.position = new Vector3(randomX, posY, randomZ);

        //     // 타겟(골)
        //     GameObject Goal = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        //     Goal.transform.localScale = new Vector3(sphereRadius,sphereRadius,sphereRadius);
		//     Goal.transform.position = new Vector3(randomX, posY+75, randomZ);

            

            // 머티리얼 적용, 수정 필요
            // Renderer Goal_Renderer = Goal.GetComponent<Renderer>();
            // if (Land_Material != null){
            //     // Renderer renderer = GetComponent<Renderer>();
            //     Goal_Renderer.material = Land_Material;
            // }

            // goalList.Add(Goal);
            // GoalTrans[i] = Goal.transform;

        // }
        // Console.WriteLine("생성된 goalList들: {0}",goalList.Count );
        // Console.ReadKey();

        Debug.Log(m_ResetParams);

        AreaTrans = gameObject.transform;
        DroneTrans = DroneAgent.transform;
        GoalTrans = Goal.transform;
        Goal2Trans = Goal2.transform;

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

        GoalTrans.position = areaInitPos + new Vector3(UnityEngine.Random.Range(-5f, 5f), UnityEngine.Random.Range(-5f, 5f), UnityEngine.Random.Range(-5f, 5f));
        Goal2Trans.position = areaInitPos + new Vector3(UnityEngine.Random.Range(-5f, 5f), UnityEngine.Random.Range(-5f, 5f), UnityEngine.Random.Range(-5f, 5f));
    }

    // public void SearchGoal(){
    //     for(int i = 0; i<numOfGoals;i++){
    //         Math.Sqrt(Math.Pow(GoalTrans[i].position.x,2) + Math.Pow(GoalTrans[i].position.y,2));
    //     }
    // }

    public void MoveDronePos(){
        
    }
}

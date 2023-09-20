using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.MLAgents;
using System;



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
    // public GameObject Goal;

    Vector3 areaInitPos;
    Vector3 droneInitPos;
    // 에피소드 종료 후 드론을 초기 회전량으로 리셋하기 위해 초기 회전량 정보를 저장
    Quaternion droneInitRot;

    EnvironmentParameters m_ResetParams;        // 학습에 필요한 인자들을 관리

    private Transform AreaTrans;        // Area 오브젝트의 위치, 회전 정보
    private Transform DroneTrans;
    public Transform GoalTrans;

    private Rigidbody DroneAgent_Rigidbody;

    // 70개의 골 위치가 포함될 리스트 작성
    List<GameObject> goalList = new List<GameObject>();

    void Start()
    {
        for (i = 0; i<numOfGoals; i++){
            float randomX = UnityEngine.Random.Range(-50f, 50f);      // 500f
            float randomZ = UnityEngine.Random.Range(-50f, 50f);      // 500f

            GameObject plane = GameObject.CreatePrimitive(PrimitiveType.Plane);
            plane.transform.localScale = new Vector3(planeSize, 1f, planeSize);
            plane.transform.position = new Vector3(0f, 0f, 0f);

            GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            cylinder.transform.localScale = new Vector3(cylinderRadius,cylinderHeight,cylinderRadius);
		    cylinder.transform.position = new Vector3(randomX, posY, randomZ);

            GameObject Goal = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            Goal.transform.localScale = new Vector3(sphereRadius,sphereRadius,sphereRadius);
		    Goal.transform.position = new Vector3(randomX, posY+75, randomZ);

            GoalTrans = Goal.transform;

            Renderer Goal_Renderer = Goal.GetComponent<Renderer>();
            if (Land_Material != null){
                // Renderer renderer = GetComponent<Renderer>();
                Goal_Renderer.material = Land_Material;
            }

            goalList.Add(Goal);

        }
        Console.WriteLine("생성된 goalList들: {0}",goalList.Count );
        Console.ReadKey();

        Debug.Log(m_ResetParams);

        AreaTrans = gameObject.transform;
        DroneTrans = DroneAgent.transform;
        // GoalTrans = Goal.transform;

        areaInitPos = AreaTrans.position;       // 위치 정보가 저장된 position을 Vector3로 가져온다
        droneInitPos = DroneTrans.position;
        droneInitRot = DroneTrans.rotation;

        DroneAgent_Rigidbody = DroneAgent.GetComponent<Rigidbody>();
    }

    public void AreaSetting()
    {
        DroneAgent_Rigidbody.velocity = Vector3.zero;
        DroneAgent_Rigidbody.angularVelocity = Vector3.zero;

        DroneTrans.position = droneInitPos;
        DroneTrans.rotation = droneInitRot;

        // GoalTrans.position = areaInitPos + new Vector3(Random.Range(-5f, 5f), Random.Range(-5f, 5f), Random.Range(-5f, 5f));
    }

    public void MoveDronePos(){
        
    }
}

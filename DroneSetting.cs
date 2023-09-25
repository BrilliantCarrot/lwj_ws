using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.MLAgents;
using System;
using Unity.Mathematics;

public class DroneSetting : MonoBehaviour
{
    int i;
    public int numOfGoals = 6;      // 타겟인 Goal(소노부이)들의 갯수
    public Material Land_Material;
    float planeSize = 12.5f;        // 바다 표면
    float cylinderHeight = 2f;      
    float cylinderRadius = 25f;     // 탐지반경
    int sphereRadius = 4;           // 소노부이 크기
    float posY = 20f;               // 0.5f
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
    private Transform[] GoalTrans = new Transform[6];      // 생성된 목표점들의 위치를 저장할 Transform 배열 선언
    float[] Distance = new float[6];
    float preDist;
    public GameObject target;

    public DroneAgent agent;

    private Rigidbody DroneAgent_Rigidbody;

    void Start()
    {
        
        for (i = 0; i<numOfGoals; i++){
            // 타겟 Goal 생성
            Goal[i] = GameObject.Find((i+1).ToString());    

            GoalTrans[i] = Goal[i].transform;

            // // 소노부이 반경
            // GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            // cylinder.transform.localScale = new Vector3(cylinderRadius,cylinderHeight,cylinderRadius);
		    // cylinder.transform.position = new Vector3(randomX, posY, randomZ);
            // Goal의 transform 설정

            // // 타겟(골)
            // GameObject Goal = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            // Goal.transform.localScale = new Vector3(sphereRadius,sphereRadius,sphereRadius);
		    // Goal.transform.position = new Vector3(randomX, posY+75, randomZ);

            // 머티리얼 적용
            // Renderer Goal_Renderer = Goal.GetComponent<Renderer>();
            // if (Land_Material != null){
            //     // Renderer renderer = GetComponent<Renderer>();
            //     Goal_Renderer.material = Land_Material;
            // }
        }

        Debug.Log(m_ResetParams);

        AreaTrans = gameObject.transform;
        DroneTrans = DroneAgent.transform;      // 드론의 위치를 받고 저장하는 DroneTrans
        areaInitPos = AreaTrans.position;       // 위치 정보가 저장된 position을 Vector3로 가져온다
        droneInitPos = DroneTrans.position;
        droneInitRot = DroneTrans.rotation;
        DroneAgent_Rigidbody = DroneAgent.GetComponent<Rigidbody>();
    }


    // 에피소드가 시작될 때마다 실행되는 환경 초기화 함수
    public void AreaSetting()
    {
        DroneAgent_Rigidbody.velocity = Vector3.zero;
        DroneAgent_Rigidbody.angularVelocity = Vector3.zero;

        // 목표점 찾고 난 후엔 그 지점으로 가도록 설정
        DroneTrans.position = droneInitPos;
        DroneTrans.rotation = droneInitRot;

        // 드론과 가장 가까운 소노부이를 선택하는 함수

    }

    // 드론 위치로부터 최단거리 목표점 탐색
    public GameObject SearchGoal(){
        
        target = null;
        float closestDistanceSqr = Mathf.Infinity;

        for(int i = 0; i<numOfGoals;i++){
            Vector3 directionToTarget = (GoalTrans[i].position - DroneTrans.position);
            float dSqrToTarget = directionToTarget.sqrMagnitude;

            if(dSqrToTarget < closestDistanceSqr){
                closestDistanceSqr = dSqrToTarget;
                target = Goal[i];
            }
        }
        return target;
    }
    

    // 목표점에 도달한 후 드론의 위치를 목표점으로 설정
    // droneNextPos = 1f;
    // public void MoveDronePos(){
        
    // }
}

# kubectl이 CP와 분리된 경우
  CP의 `/etc/kubernetes/admin.conf`를 복사하여 사용.\
  `kubectl get nodes --kubeconfig admin.conf`

# Control plain VS worker node
### Control plain
    Declarative, not workflow.
    추구하는 상태를 API에 선언하면 다른 요소들이 현재 상태(etcd)와 비교하여 변경하는 선언적 구조.
    이미 생성된 파드들을 유기적으로 연결하고 클러스터를 안정적으로 유지하기 위함.
### worker node
    kubelet -> container runtime -> pods 과정의 워크플로우 구조.
---

# Pod life cycle
```mermaid
sequenceDiagram

box Blue Admin
participant kubectl
end

kubectl->>API: pod 생성 요청
Note over kubectl: 마스터 노드 내/외부에 구성 가능 

box Green Control_Plain
participant API
participant etcd
participant C_M
participant Sched
end

API->>etcd: 변경사항 기록
etcd->>API: 변경사항 적용 알림

API->>C_M: 파드생성 요청 감시/인지
C_M->>API: 파드 생성(배포 노드 미정)

API->>Sched: 파드 생성 감시/인지
Sched->>API: 노드 선정 및 배포요청

box Purple Worker_node
participant kubelet
participant Pod(s)
end

API->>kubelet: 정상 배포 감시/인지
kubelet->>API: 파드 상태/정보 전달

kubelet->>Pod(s): 파드 상태/정보 전달
Note over kubelet,Pod(s): container<br/>runtime
API->>kubectl: 파드 사용 가능
```
---


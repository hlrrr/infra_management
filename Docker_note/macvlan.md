# Conditions
- 무선 어댑터 사용 불가(?)
- 윈도우 환경 불가(?)
- 연결 할 호스트 네트워크와 같으 대역으로 설정.
- parent 어댑터에 따라 vlan tag 요구(다수 macvlan 네트워크를 vlan tag로 한번 더 그룹화 가능)
- 호스트와는 직접 통신을 위한 별도 설정 필요.
- 브릿지 네트워크보다 고성능, 컨테이너의 용도에 따라 고려해 볼만.

```
docker network create -d macvlan \
    --subnet=192.168.1.0/24 \
    --gateway=192.168.1.1 \
    -o parent=eth0 \
    my_macvlan_network
```
```
services:
  DHCP:
    image: rockylinux:8.9
    container_name: rk09_dhcp
    command: /bin/bash
    stdin_open: true  # -i (interactive) 플래그와 비슷한 역할
    tty: true         # -t 플래그와 비슷한 역할
    # ports:
    #   - 10000:10000
    networks:
      mvnet:
        ipv4_address: 11.1.1.11 # 컨테이너에 할당할 고정 IP

  Client:
    image: rockylinux:8.9
    container_name: rk09_client
    command: /bin/bash
    stdin_open: true  # -i (interactive) 플래그와 비슷한 역할
    tty: true         # -t 플래그와 비슷한 역할
    # ports:
    #   - 10001:10001
    networks:
      mvnet:
        ipv4_address: 11.1.1.22 # 컨테이너에 할당할 고정 IP

networks:
  mvnet:
    external: true
```

# Macvaln과 Vlan
| **MACVLAN** | **VLAN (802.1Q)** | 
| --- | --- | 
| 하나의 물리적 NIC에서 여러 MAC 주소를 통해 다수의 가상 네트워크 인터페이스를 생성 | 이더넷 프레임에 VLAN 태그(802.1Q)를 추가하여 네트워크 트래픽을 논리적으로 구분, 스위치 및 라우터를 통해 트래픽 관리 |
| MAC 주소를 기반으로 네트워크를 분리, 자체 IP 주소를 가질 수 있음 | VLAN 태그(예: VLAN ID 10, 20)를 기반으로 트래픽이 특정 VLAN에 속함을 표시|
| MAC 주소가 많아지면 네트워크 스위치의 MAC 주소 테이블 크기를 초과할 위험 | VLAN 태그를 처리할 수 있는 스위치가 필요하며, 추가 설정이 필요 |


# Storage Area Network (SAN)
### 호스트 버스 어댑터 (Host Bus Adapter, HBA)
HBA는 서버(호스트)가 SAN에 연결될 수 있도록 해주는 인터페이스 카드. 
서버와 스토리지 간의 데이터 전송을 처리하고, Fibre Channel, iSCSI와 같은 다양한 프로토콜을 지원.

### 스토리지 장치 (Storage Devices)
SAN 내의 물리적 스토리지 장치로, 주로 하드 디스크 드라이브(HDD)나 솔리드 스테이트 드라이브(SSD)가 사용.
고속 스토리지 어레이에 구성되어 RAID, 데이터 중복 제거, 스냅샷 등 다양한 기능을 제공.

### 스위치 (Switches)
SAN 네트워크 내에서 데이터가 원활하게 전송되도록 돕는 네트워크 스위치.
Fibre Channel Switch가 일반적으로 사용되며, SAN에서 스토리지 트래픽을 관리하고 최적의 경로를 제공.

### 케이블과 커넥터 (Cables and Connectors)
서버, 스토리지 장치, 스위치 등을 연결하는 데 사용되는 물리적 케이블 및 커넥터.
Fibre Channel을 사용하는 경우 광섬유 케이블이 사용되며, iSCSI의 경우 고속 이더넷 케이블이 필요.

### 스토리지 관리 소프트웨어 (Storage Management Software)
SAN을 효과적으로 관리하기 위한 소프트웨어로, LUN(Logical Unit Number) 할당, 데이터 보호, 성능 모니터링 등을 수행.
SAN 관리자는 이 소프트웨어를 통해 연결된 장치들을 효율적으로 관리.

## SAN vs NAS  
| 특징         |  SAN (Storage Area Network)	                       |  SAN (Storage Area Network)                      	|
| ---         | ---                                                   | ---                                               |
| 접근 방식    | **블록 레벨** (로컬 디스크처럼 인식)	                   | **파일 레벨** (파일 서버처럼 접근)               |
| 프로토콜     | Fibre Channel, iSCSI		                              | NAS 장치에 파일 시스템 내장                         |
| 파일 시스템  | 클라이언트(서버)가 자체 파일 시스템 관리	              | 파일 단위 전송으로 속도가 상대적으로 느림             |
| 속도 및 성능 | 높은 성능, 낮은 지연 시간 (고성능 워크로드에 적합)       | 파일 단위 전송으로 속도가 상대적으로 느림             |
| 사용 용도    |	 데이터베이스, 가상 머신, 트랜잭션 등 고성능 애플리케이션 | 파일 공유, 백업, 파일 서버 등 여러 클라이언트가 사용 |

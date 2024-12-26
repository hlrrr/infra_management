# Commands
- 기본 정보: `lspci, lsblk, dmesg`
- 세부 정보:
  ```
  # sysfsutils 패키지
  systool -c fc_host -v

  # 장치 정보 관련 디렉토리
  /sys/class/fc_host
  ```
- 드라이버 정보: 
  ```
  modinfo, ethtool

  modinfo qla2xxx  (Qlogic)
  modinfo lpfc  (Emulex)

  lsmod | grep lpfc  (모듈 로드 확인)
  ```
- 연결 장치 확인: `lsscsi`

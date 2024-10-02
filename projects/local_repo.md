# 폐쇄망을 위한 로컬 저장소 구축
 사내 폐쇄망의 리눅스 서버들을 위한 로컬 저장소를 구성하려고 한다. 설치 할 패키지들은 온라인 환경에서 외부 저장장치에 다운로드하고, 해당 저장치는 폐쇄망의 다목적 서버에 마운트하여 로컬 저장소로서 활용한다.
 
## 외부 저장장치 활용
- 연결된 usb 장치(sdc)와 마운트된 디렉토리(/mnt/usb)
  ```
  root@prxmx:~# lsblk | grep sdc
  sdc                                          8:32   1  14.6G  0 disk 
  └─sdc1                                       8:33   1  14.6G  0 part /mnt/usb
  
  root@prxmx:~# mount | grep usb
  /dev/sdc1 on /mnt/usb type ext4 (rw,relatime)
  ```
  
- 설치 할 패키지들은  /mnt/usb/pkgs 디렉토리에 저장
  ```
  [root@Server ~]# ls -t /mnt/usb/pkgs/
  
  repodata                                     
  ncftp-3.2.5-23.el9.x86_64.rpm                glibc-gconv-extra-2.34-100.el9_4.3.x86_64.rpm
  which-2.21-29.el9.x86_64.rpm                 gpm-libs-1.20.7-29.el9.x86_64.rpm
  ...
  ```

- 아래 명령어를 통해 패키지(의존성 포함) 다운로드 및 경로 지정.\
  `dnf download --resolve --alldeps --destdir=/mnt/usb/pkgs -y {패키지명}`

- 패키지 추가 후 createrepo 도구를 이용해 패키지 메타데이터 생성
  ```
  [root@Server ~]# createrepo /mnt/usb/pkgs
  
  [root@Server ~]# ls -t /mnt/usb/pkgs/repodata/
  
  repomd.xml
  9ec23bc42e0cdbbd4ffbcec8331181615e37347f78726413df10f331999413a8-filelists.sqlite.bz2
  425ff991895c513b4bf1c0325dc1aabf190eafcc7199004de122018427007a5b-primary.sqlite.bz2
  ...
  ```

## vsFTP를 활용한 로컬저장소 서버(선택)

- vsftp 설치 및 접근성 설정, ftp 접속 경로를 설치할 패키지들이 있는 디렉토리로 설정한다
  ```
  [root@Server ~]# vim /etc/vsftpd/vsftpd.conf
  
  ...
  # Allow anonymous FTP? (Beware - allowed by default if you comment this out).
  anonymous_enable=yes  
  anon_root=/mnt/usb/pkgs
  ...
  ```  

- ftp 클라이언트 도구를 이용해 접속 및 패키지 디렉토리 확인
  ```
  [root@zulu ~]# ftp alpha.node
  
  Connected to alpha.node (10.1.1.9).
  220 (vsFTPd 3.0.5)
  Name (alpha.node:root): anonymous
  331 Please specify the password.
  Password:
  230 Login successful.
  Remote system type is UNIX.
  Using binary mode to transfer files.
  
  ftp> ls
  227 Entering Passive Mode (10,1,1,9,69,131).
  150 Here comes the directory listing.
  -rwxr-xr-x    1 988      988          6565 Sep 05 14:31 basesystem-11-13.el9.0.1.noarch.rpm
  -rwxr-xr-x    1 988      988       1738842 Sep 05 14:31 bash-5.1.8-9.el9.x86_64.rpm
  -rwxr-xr-x    1 988      988       1117085 Sep 05 14:31 filesystem-3.16-2.el9.x86_64.rpm
  ...
  ```
  
##  Nginx를 활용한 로컬저장소 서버(선택)
별도의 ftp서버 사용이 불가능 하거나 기존에 사용중인 Nginx서버가 있는 경우, 이를 활용하여 로컬 저장소를 구성 할 수 있다.

- Nginx 설치 및 설정, 로컬 저장소 주소(location)와 실제 패키지 파일의 경로`/mnt/usb/pkgs/`를 입력
  ```
  [root@Server ~]#  cat /etc/nginx/conf.d/repo.conf
  
  server {
      listen 80;
      server_name 10.1.1.9;
  
      location /repo/ {
          alias /mnt/usb/pkgs/;       # 패키지 파일 경로(alias/root 이용시, 마지막 “/” 유무에 주의)
          autoindex on;               # 디렉토리 인덱싱(index.html 불필요)
          autoindex_exact_size off;   # 파일사이즈 표시 방법
          autoindex_localtime on;     # 수정시간 로컬라이즈
      }
  }
  ```

- nginx 서버에 접속하여 패키지 목록 확인
  ```
  [root@zulu ~]# curl 10.1.1.9/repo/
  
  <html>
  <head><title>Index of /repo/</title></head>
  <body>
  <h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
  <a href="repodata/">repodata/</a>                                          05-Sep-2024 17:50       -
  <a href="basesystem-11-13.el9.0.1.noarch.rpm">basesystem-11-13.el9.0.1.noarch.rpm</a>              05-Sep-2024 14:31    6565
  <a href="bash-5.1.8-9.el9.x86_64.rpm">bash-5.1.8-9.el9.x86_64.rpm</a>                        05-Sep-2024 14:31      2M
  ...
  ```

## Ansible를 활용한 로컬 저장소 사용 설정
ftp 혹은 Nginx를 활용한 로컬 저장소 구성이 끝났다면, 네트워크 상의 다른 서버들이 해당 저장소를 사용할 수 있도록 설정해야한다. 
다수의 서버에 동일한 작업을 반복해야 하므로 Ansible을 사용해 효율적으로 작업하려고 한다.

- Ansible 설치 및 서버 목록 작성
  ```
  [root@Server ~]# cat   /etc/ansible/hosts

  [nodes]
  zulu ansible_host=10.1.1.1    
  yank ansible_host=10.1.1.2    
  xray ansible_host=10.1.1.3    
  
  [local]
  10.1.1.9
  ```

- 목록의 서버들과 ping 테스트
  ```
  [root@Server ~]# ansible nodes -m ping
  
  yank | SUCCESS => {
      "ansible_facts": {
          "discovered_interpreter_python": "/usr/bin/python3"
      },
      "changed": false,
      "ping": "pong"
  }
  xray | SUCCESS => {
      "ansible_facts": {
          "discovered_interpreter_python": "/usr/bin/python3"
      },
      "changed": false,
      "ping": "pong"
  }
  zulu | SUCCESS => {
      "ansible_facts": {
          "discovered_interpreter_python": "/usr/bin/python3"
      },
      "changed": false,
      "ping": "pong"
  }
  ```

## Ansible Playbook 활용한 로컬 저장소 사용 설정
  
- 비밀번호 대신 사용 할 ssh키를 생성하고 대상 서버들에 키를 복사한다.
  https://github.com/hlrrr/infra_management/blob/9e28f797fca7a2a3a4fbfa04cde52fc23c74dbce/Ansible_note/book_localRepo.yml#L5-L9


- 폐쇄망으로 운영하고, 로컬 저장소를 사용하기 때문에 OS에 기본적으로 포함된 .repo파일들은 사용 비활성화 한다(enable=0) \
  dnf 캐시는 정리하고 추가한 .repo가 목록에 나타나는지 확인
  https://github.com/hlrrr/infra_management/blob/ce240905a3b6815f94956eaafb2b2fc7b5acdd53/Ansible_note/book_localRepo.yml#L11-L17

- 서버들에 추가할 .repo 파일 내용에 nginx 혹은 ftp url을 추가하고 활성화 한다(enabled). 필요에 따라 우선순위를 설정한다(priority)
  https://github.com/hlrrr/infra_management/blob/ce240905a3b6815f94956eaafb2b2fc7b5acdd53/Ansible_note/book_localRepo.yml#L19-L36


## Ansible Playbook 실행 및 확인
- playbook 파일 실행 후, 대상 서버에서 dnf를 이용한 패키지 설치시 설정한 로컬 저장소를 사용하는 지 확인
  ```
  [root@zulu ~]# dnf repolist
  repo id                                                                     repo name
  myrepo                                                                      My ngnix Repo

  [root@zulu ~]# dnf install vim
  Last metadata expiration check: 0:13:32 ago on Wed 02 Oct 2024 05:46:44 AM UTC.
  Dependencies resolved.
  =============================================================================================================================================================
   Package                                 Architecture                    Version                                       Repository                       Size
  =============================================================================================================================================================
  Installing:
   vim-enhanced                            x86_64                          2:8.2.2637-20.el9_1                           myrepo                          1.8 M
  Installing dependencies:
   gpm-libs                                x86_64                          1.20.7-29.el9                                 myrepo                           20 k
   vim-common                              x86_64                          2:8.2.2637-20.el9_1                           myrepo                          6.6 M
   vim-filesystem                          noarch                          2:8.2.2637-20.el9_1                           myrepo                           14 k
   which                                   x86_64                          2.21-29.el9                                   myrepo                           40 k
  
  Transaction Summary
  =============================================================================================================================================================
  Install  5 Packages
  ...
  ```

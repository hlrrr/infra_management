# DNS 서버 구축 
 사내 서버들간 호출이 필요할 경우 매번 ip주소를 입력하기 번거롭고 기억하기도 쉽지 않다. 이에 다목적 서버에 DNS서버를 구축하고 협의 한 규칙에 따라 서버에 도메인을 부여하고자 한다.

## bind 설치 및 설정


- DNS 서버 구축에 필요한 패키지(bind, bind-tools)를 설치하고 설정파일에 필요한 내용을 입력
  ```
  /etc/named.rfc1912.zones
  
  ... 
  
  zone "alpha.node" IN {
      type master;
      file "alpha.node.db";
      allow-update { none; };
  };
  
  zone "xray.node" IN {
      type master;
      file "xray.node.db";
      allow-update { none; };
  };
  
  zone "yank.node" IN {
      type master;
      file "yank.node.db";
      allow-update { none; };
  };
  
  zone "zulu.node" IN {
      type master;
      file "zulu.node.db";
      allow-update { none; };
  };
  ```

- 설정파일에 입력한 도메인에 대한 zone파일을 생성하고 내용을 입력
  ```
  /var/named/zulu.node.db
  
  ...
  
  ; A records for name servers
        NS   @
  
  ; A records for other hosts
        A   10.1.1.1
  ```
  
- `named-checkconf / named-checkzone` 을 통해 설정파일의 오류를 사전에 검사할 수 있다.
  
## nslookup 결과 확인
설정파일 작성이 완료되면 named 서비스를 재시작하고 설정한 도메인과 대상의 ip addr.이 제대로 연결되었는지 확인
 ```
[root@Server ~]# nslookup zulu.node
 Server:         10.1.1.9
 Address:        10.1.1.9#53
 
 Name:   zulu.node
 Address: 10.1.1.1
 
 [root@Server ~]# nslookup yank.node
 Server:         10.1.1.9
 Address:        10.1.1.9#53
 
 Name:   yank.node
 Address: 10.1.1.2
 
 [root@Server ~]# nslookup xray.node
 Server:         10.1.1.9
 Address:        10.1.1.9#53
 
 Name:   xray.node
 Address: 10.1.1.3
 ```



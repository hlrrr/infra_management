- 리전 당 최대 5개.(요청하여 추가 가능)
- subnet 생성 시, 사용할 서비스/인스터스를 지원하는 AZ를 미리 확인할 것.
- vpc 개별 생성시
  - subnet(public), internet gateway, routing table(필요시) 생성.
  - attach IG to VPC
  - associate subnet to routing table
  - edit routes

# Recover default VPC
```
aws ec2 create-default-subnet --availability-zone us-west-2a
```


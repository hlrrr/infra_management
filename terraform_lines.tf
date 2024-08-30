# Terraform 초기화
provider "aws" {
	region = "ap-northeast-2"  # 원하는 AWS 리전으로 설정
}

# VPC 생성 (기본 VPC 사용 시 생략 가능)
resource "aws_vpc" "demo_vpc" {
	cidr_block = "11.0.0.0/16"
  	tags = {
    	Name = "demo-vpc"
 	}
}

# 프라이빗 서브넷
## 프라이빗 서브넷 1 생성 
resource "aws_subnet" "demo_subnet_private_1" {
	vpc_id            = aws_vpc.demo_vpc.id
	cidr_block        = "11.0.1.0/24"
	availability_zone = "ap-northeast-2a"  # 원하는 가용 영역으로 설정
	tags = {
    	Name = "demo-subnet-private-1"
 	}
}

## 프라이빗 서브넷 2 생성 
resource "aws_subnet" "demo_subnet_private_2" {
	vpc_id            = aws_vpc.demo_vpc.id
	cidr_block        = "11.0.3.0/24"
	availability_zone = "ap-northeast-2b"  # 원하는 가용 영역으로 설정
	tags = {
    	Name = "demo-subnet-private-2"
 	}
}

## 라우팅 테이블 생성
resource "aws_route_table" "demo_private_rt" {
	vpc_id = aws_vpc.demo_vpc.id
 	tags = {
    	Name = "demo-private-rt"
  	}
	# # 기본적으로 로컬 트래픽에 대한 경로만 추가 , VPC CIRD와 같을 경우 불필요(에러발생)
	# route {
	# 	cidr_block = "11.0.0.0/16"	
	# 	gateway_id = "local"  # VPC 내부 트래픽은 로컬로 처리
	# }
}

# 프라이빗 서브넷을 라우팅 테이블에 연결
resource "aws_route_table_association" "demo_private_1_rt_assoc" {
	subnet_id      = aws_subnet.demo_subnet_private_1.id
	route_table_id = aws_route_table.demo_private_rt.id
}
resource "aws_route_table_association" "demo_private_2_rt_assoc" {
	subnet_id      = aws_subnet.demo_subnet_private_2.id
	route_table_id = aws_route_table.demo_private_rt.id
}

# 퍼블릿 서브넷 
## 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "demo_igw" {
	vpc_id = aws_vpc.demo_vpc.id
	tags = {
    	Name = "demo-igw"
  	}
}

## 퍼블릭 서브넷 생성
resource "aws_subnet" "demo_subnet_public" {
	vpc_id            = aws_vpc.demo_vpc.id
	cidr_block        = "11.0.2.0/24"
	availability_zone = "ap-northeast-2a"  # 원하는 가용 영역으로 설정
	map_public_ip_on_launch = true  # 퍼블릭 IP를 자동으로 할당
	tags = {
    	Name = "demo_subnet_public"
  	}

}

## 라우팅 테이블 생성
resource "aws_route_table" "demo_public_rt" {
	vpc_id = aws_vpc.demo_vpc.id
	tags = {
    	Name = "demo-private-rt"
  	}
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.demo_igw.id  # 인터넷 트래픽
	}
	# # 기본적으로 로컬 트래픽에 대한 경로만 추가 , VPC CIRD와 같을 경우 불필요(에러발생)
	# route {
	# 	cidr_block = "11.0.0.0/16"	
	# 	gateway_id = aws_internet_gateway.demo_igw.id
	# }
}

## 서브넷을 라우팅 테이블에 연결
resource "aws_route_table_association" "demo_public_rt_assoc" {
	subnet_id      = aws_subnet.demo_subnet_public.id
	route_table_id = aws_route_table.demo_public_rt.id
}

# EC2 인스턴스 보안 그룹 생성
resource "aws_security_group" "demo_sg" {
	vpc_id = aws_vpc.demo_vpc.id
	name = "demo-sg"
	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]  # SSH를 위한 포트 열기
	}
	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"  # 모든 프로토콜 허용
		cidr_blocks = ["0.0.0.0/0"]
	}
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # HTTP를 위한 포트 열기
#   }
}

# EC2 인스턴스 생성
resource "aws_instance" "demo_bastion" {
	ami           = "ami-008d41dbe16db6778"  # 원하는 AMI ID로 설정 (예: amz linux)
	instance_type = "t2.micro"  # 인스턴스 타입 선택
	subnet_id     = aws_subnet.demo_subnet_public.id
	vpc_security_group_ids = [aws_security_group.demo_sg.id]
	tags = {
		Name = "demo-bastion"
	}
}

# 데이터베이스 생성
## RDS 보안 그룹 생성
resource "aws_security_group" "demo_rds_sg" {
	vpc_id = aws_vpc.demo_vpc.id	# vpc id 미미정시 새로운  vpc 생성 - 보안그룹/RDS와 미스매치
  	name = "demo-rds-security-group"
	ingress {
		from_port   = 3306
		to_port     = 3306
		protocol    = "tcp"
		cidr_blocks = ["11.0.0.0/16"]  # 외부에서의 접속을 허용하는 규칙. 필요에 따라 수정
	}
	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## 서브넷 그룹 생성
resource "aws_db_subnet_group" "demo_db_subnetgroup" {
  name       = "demo-db-subnet-group"
  subnet_ids = [aws_subnet.demo_subnet_private_1.id, aws_subnet.demo_subnet_private_2.id]
  tags = {
    Name = "demo-db-subnet-group"
  }
}

## RDS 인스턴스 생성
resource "aws_db_instance" "demo_maria" {
	allocated_storage    = 20
	identifier           = "demo-maria"					
	engine               = "mariadb"
	engine_version       = "10.11.9"
	instance_class       = "db.t3.micro"	# free tier
	username             = "demoadmin"
	password             = "demopasswd"  # 실제 사용 시, 보안 Vault에 저장하거나 환경 변수 사용 권장
	db_subnet_group_name = aws_db_subnet_group.demo_db_subnetgroup.name
	vpc_security_group_ids = [aws_security_group.demo_rds_sg.id]
	skip_final_snapshot  = true                  # 삭제 시 최종 스냅샷 생성을 건너뜀
}

output "ec2_instance_public_ip" {
	value = aws_instance.demo_bastion.public_ip
}
output "rds_endpoint" {
	value = aws_db_instance.demo_maria.endpoint
}

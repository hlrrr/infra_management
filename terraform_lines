provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-045f2d6eeb07ce8c0"
  instance_type = "t2.micro"
  count = 2
  
  tags = {
    Name = "4gl_${count.index + 1}"
  }
}


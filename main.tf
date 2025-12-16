########################################
# TERRAFORM & PROVIDER (STABLE)
########################################
terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.46.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

########################################
# VPC
########################################
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "trend-vpc"
  }
}

########################################
# INTERNET GATEWAY
########################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "trend-igw"
  }
}

########################################
# PUBLIC SUBNET
########################################
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "trend-public-subnet"
  }
}

########################################
# ROUTE TABLE
########################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name =   "trend-public-rt"
  }
}

  resource "aws_route_table_association" "rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins"
  vpc_id      = aws_vpc.main_vpc.id  

   ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "jenkins-key"

  tags = {
    Name = "Jenkins-Server"
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}


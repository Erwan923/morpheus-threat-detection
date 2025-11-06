terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for latest Ubuntu 22.04 LTS with GPU support
data "aws_ami" "ubuntu_gpu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC
resource "aws_vpc" "morpheus" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.instance_name}-vpc"
    Project = "morpheus-threat-detection"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "morpheus" {
  vpc_id = aws_vpc.morpheus.id

  tags = {
    Name    = "${var.instance_name}-igw"
    Project = "morpheus-threat-detection"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.morpheus.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.instance_name}-public-subnet"
    Project = "morpheus-threat-detection"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.morpheus.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.morpheus.id
  }

  tags = {
    Name    = "${var.instance_name}-public-rt"
    Project = "morpheus-threat-detection"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "morpheus" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Morpheus Threat Detection"
  vpc_id      = aws_vpc.morpheus.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
    description = "SSH access"
  }

  # Triton HTTP
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Triton HTTP"
  }

  # Triton gRPC
  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Triton gRPC"
  }

  # Triton Metrics
  ingress {
    from_port   = 8002
    to_port     = 8002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Triton Metrics"
  }

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus"
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name    = "${var.instance_name}-sg"
    Project = "morpheus-threat-detection"
  }
}

# EC2 Instance
resource "aws_instance" "morpheus" {
  ami                    = data.aws_ami.ubuntu_gpu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.morpheus.id]
  key_name               = var.key_name != "" ? var.key_name : null

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    instance_name = var.instance_name
  })

  instance_market_options {
    market_type = var.spot_instance ? "spot" : null
    
    dynamic "spot_options" {
      for_each = var.spot_instance ? [1] : []
      content {
        max_price          = var.spot_max_price
        spot_instance_type = "one-time"
      }
    }
  }

  tags = {
    Name    = var.instance_name
    Project = "morpheus-threat-detection"
    Type    = "GPU-Accelerated"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

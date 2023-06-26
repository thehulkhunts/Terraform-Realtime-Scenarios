// creating a vpc resource 

resource "aws_vpc" "vpc-prod" {

  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.vpc_tenancy
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-for-prod"
    Environment = "prod"
  }

}

// two public subnets 01,02

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.vpc-prod.id

  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_availability_zone-01

  tags = {
    Name        = "public-subnet-01"
    Environment = "Prod"
  }

}

resource "aws_subnet" "public-subnet-02" {
  vpc_id = aws_vpc.vpc-prod.id

  cidr_block              = var.subnet_cidr-01
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_availability_zone-02

  tags = {
    Name        = "public-subnet-02"
    Environment = "prod"

  }
}

// one internet-gateway
resource "aws_internet_gateway" "igw-prod" {
  vpc_id = aws_vpc.vpc-prod.id

  tags = {
    Name        = "igw-prod"
    Environment = "prod"
  }

}

// route table for public subnets - igw 
resource "aws_route_table" "route-01" {
  vpc_id = aws_vpc.vpc-prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-prod.id
  }
}

// route table association with subnets 
resource "aws_route_table_association" "subnet-rt-01" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.route-01.id
}

resource "aws_route_table_association" "subnet-rt-02" {
  subnet_id      = aws_subnet.public-subnet-02.id
  route_table_id = aws_route_table.route-01.id
}

// private subnet and its routes and its nat-gateway

resource "aws_subnet" "private-subnet-01" {
  vpc_id = aws_vpc.vpc-prod.id

  cidr_block        = var.private_subnet_cidr-01
  availability_zone = var.subnet_availability_zone-01

  tags = {
    Name        = "private-subnet-01"
    Environment = "prod"
  }
}


resource "aws_subnet" "private-subnet-02" {
  vpc_id = aws_vpc.vpc-prod.id

  cidr_block        = var.private_subnet_cidr-02
  availability_zone = var.subnet_availability_zone-01

  tags = {
    Name        = "private-subnet-02"
    Environment = "prod"
  }
}

// elastic-ip's (2)

resource "aws_eip" "elastic-ip" {
  vpc = true

  tags = {
    Name = "eip-01"
  }
}

resource "aws_eip" "elastic-ip-02" {
  vpc = true

  tags = {
    Name = "eip-02"
  }
}

// two nat-gateways for private subnets 

resource "aws_nat_gateway" "nat-01" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name        = "nat-gateway-01"
    Environment = "prod"
  }

  depends_on = [aws_internet_gateway.igw-prod]
}

resource "aws_nat_gateway" "nat-02" {
  allocation_id = aws_eip.elastic-ip-02.id
  subnet_id     = aws_subnet.public-subnet-02.id

  tags = {
    Name = "nat-gate-way-02"
    Env  = "prod"
  }
  depends_on = [aws_internet_gateway.igw-prod]
}

// route table for private subnets 
resource "aws_route_table" "rt-private-01" {
  vpc_id = aws_vpc.vpc-prod.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-01.id
  }
}
resource "aws_route_table" "rt-private-02" {
  vpc_id = aws_vpc.vpc-prod.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-02.id
  }
}

// private subnet association with route tables 
resource "aws_route_table_association" "rt-association" {
  subnet_id      = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.rt-private-01.id
}

resource "aws_route_table_association" "rt-association-02" {
  subnet_id      = aws_subnet.private-subnet-02.id
  route_table_id = aws_route_table.rt-private-02.id
}

// create an instance in public-subnet

resource "aws_instance" "public-subnet-instance-01" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public-subnet.id
  user_data              = file("install_docker.sh")
  vpc_security_group_ids = [aws_security_group.sg-01.id]
 

  tags = {
    Name = "docker-instance"
    Env  = "prod"
  }
}
// create an instance in private subnets

resource "aws_instance" "private-instance-01" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private-subnet-01.id
  user_data              = file("install_git.sh")
  vpc_security_group_ids = [aws_security_group.sg-01.id]
 


  tags = {
    Name = "git-instance_private"
    Env  = "Prod"
  }
}

// defining ingress-egress rules in locals
locals {
  ingress_rules = [
    {
      port        = 22
      description = "allow ssh port"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 8080
      description = "allow random port for ingress"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      description = "allow https port"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      port        = 0
      description = "egress traffic"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

// creating security group
resource "aws_security_group" "sg-01" {
  vpc_id = aws_vpc.vpc-prod.id

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {

      from_port   = ingress.value.port
      to_port     = ingress.value.port
      description = ingress.value.description
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }

  }

  dynamic "egress" {
    for_each = local.egress_rules

    content {

      from_port   = egress.value.port
      to_port     = egress.value.port
      description = egress.value.description
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }

  }

}



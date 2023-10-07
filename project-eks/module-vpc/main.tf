resource "aws_vpc" "eks-vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-eks"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.subnet_cidr_01
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "public-subnet-eks"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb" = 1
  }

}

resource "aws_subnet" "subnet-02" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.subnet_cidr_02
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"

  tags = {
      Name = "public-subnet-eks-02"
     "kubernetes.io/cluster/eks" = "shared"
     "kubernetes.io/role/elb" = 1
  }
}
resource "aws_subnet" "private-subnet-01" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.private_subnet_cidr_01
  availability_zone       = "ap-south-1a"

  tags = {
      Name = "private-subnet-eks-01"
     "kubernetes.io/cluster/eks" = "shared"
     "kubernetes.io/role/elb" = 1
  }
}
resource "aws_subnet" "private-subnet-02" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.private_subnet_cidr_02
  availability_zone       = "ap-south-1b"

  tags = {
      Name = "private-subnet-eks-02"
     "kubernetes.io/cluster/eks" = "shared"
     "kubernetes.io/role/elb" = 1
  }
}
resource "aws_internet_gateway" "eks-igw" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "igw-eks"
  }
}

resource "aws_route_table" "eks-rt" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-igw.id

  }

  tags = {
    Name = "rt-eks"
  }
}

resource "aws_route_table_association" "eks-rt-ass" {
  route_table_id = aws_route_table.eks-rt.id
  subnet_id      = aws_subnet.public-subnet.id
}

resource "aws_route_table_association" "eks-rt-ass-02" {
  route_table_id = aws_route_table.eks-rt.id
  subnet_id      = aws_subnet.subnet-02.id
}


output "subnet-01" {
  value = aws_subnet.public-subnet.id
}

output "subnet-02" {
  value = aws_subnet.subnet-02.id
}

output "vpc_id" {
  value = aws_vpc.eks-vpc.id
}

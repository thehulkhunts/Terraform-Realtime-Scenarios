resource "aws_vpc" "auto-scaling-vpc" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.env}-vpc"
    }
}

resource "aws_subnet" "public-subnet-01" {
   cidr_block = var.subnet_cidr-01
   vpc_id = aws_vpc.auto-scaling-vpc.id
   map_public_ip_on_launch = true
   availability_zone = var.az

   tags = {
    Name = "${var.env}-subnet"
   }
}

resource "aws_subnet" "public-subnet-02" {
   cidr_block = var.subnet_cidr-02
   vpc_id = aws_vpc.auto-scaling-vpc.id
   map_public_ip_on_launch = true
   availability_zone = var.az-02

   tags = {
    Name = "${var.env}-subnet-02"
   }
}

resource "aws_subnet" "private-subnet-01" {
   cidr_block = var.subnet_cidr-03
   vpc_id = aws_vpc.auto-scaling-vpc.id
   availability_zone = var.az

   tags = {
    Name = "${var.env}-private-subnet-01"
   }
}

resource "aws_subnet" "private-subnet-02" {
   cidr_block = var.subnet_cidr-04
   vpc_id = aws_vpc.auto-scaling-vpc.id
   availability_zone = var.az-02

   tags = {
    Name = "${var.env}-private-subnet-02"
   }
}
resource "aws_internet_gateway" "asg-igw" {
    vpc_id = aws_vpc.auto-scaling-vpc.id

    tags = {
        Name = "${var.env}-igw"
    }
}

resource "aws_eip" "elastic-ip" {
   vpc = true

   tags = {
    Name = "eip-asg"
   }
}

resource "aws_eip" "elastic-ip-02" {
   vpc = true

   tags = {
    Name = "eip-asg-02"
   }
}

resource "aws_nat_gateway" "nat-gateway-asg" {
   allocation_id = aws_eip.elastic-ip.id
   subnet_id = aws_subnet.private-subnet-01.id

    tags = {
        Name = "nat-01"
    }
    depends_on = [ aws_internet_gateway.asg-igw ]
}

resource "aws_nat_gateway" "nat-gateway-asg-02" {
   allocation_id = aws_eip.elastic-ip-02.id
   subnet_id = aws_subnet.private-subnet-02.id

    tags = {
        Name = "nat-02"
    }
    depends_on = [ aws_internet_gateway.asg-igw ]
}
resource "aws_route_table" "asg-rt" {
    vpc_id = aws_vpc.auto-scaling-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.asg-igw.id
    }
      tags = {
        Name = "${var.env}-public-rt"
    }
}
resource "aws_route_table" "pvt-asg-rt" {
    vpc_id = aws_vpc.auto-scaling-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gateway-asg-02.id
    }
      tags = {
        Name = "${var.env}-pvt-rt"
    }
}

resource "aws_route_table" "pvt-asg-rt-02" {
    vpc_id = aws_vpc.auto-scaling-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gateway-asg.id
    }
      tags = {
        Name = "${var.env}-pvt-rt-02"
    }
}
resource "aws_route_table_association" "asg-rt-ass" {
    route_table_id = aws_route_table.asg-rt.id
    subnet_id = aws_subnet.public-subnet-01.id
}

resource "aws_route_table_association" "asg-rt-ass-02" {
    route_table_id = aws_route_table.asg-rt.id
    subnet_id = aws_subnet.public-subnet-02.id
}

resource "aws_route_table_association" "pvt-rt-asg" {
   route_table_id = aws_route_table.pvt-asg-rt.id
   subnet_id = aws_subnet.private-subnet-01.id
}

resource "aws_route_table_association" "pvt-rt-asg-02" {
   route_table_id = aws_route_table.pvt-asg-rt-02.id
   subnet_id = aws_subnet.private-subnet-02.id
}
output "vpc" {
  value = aws_vpc.auto-scaling-vpc.id
}

output "subnet-01" {
  value = aws_subnet.public-subnet-01.id
}

output "subnet-02" {
  value = aws_subnet.public-subnet-02.id
}

output "pvt-subnet-01" {
  value = aws_subnet.private-subnet-01.id
}

output "pvt-subnet-02" {
  value = aws_subnet.private-subnet-02.id
}
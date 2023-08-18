resource "aws_security_group" "eks-vpc-sg" {
  vpc_id = var.vpc_id

  name        = "security-group-eks-vpc"
  description = "security group for eks-ssh allowed"

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
    self             = false
    prefix_list_ids  = []
    security_groups  = []
    ipv6_cidr_blocks = ["::/0"]

  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    protocol         = -1
    from_port        = 0
    to_port          = 0
    self             = false
    prefix_list_ids  = []
    security_groups  = []
    ipv6_cidr_blocks = ["::/0"]
  }
}

output "security_group" {
  value = aws_security_group.eks-vpc-sg.id
}
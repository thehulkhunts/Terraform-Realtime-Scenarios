resource "aws_instance" "instance-01" {
  ami                    = var.ami-image
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data              = "${file("install_docker.sh")}"


  tags = {
    Name = "Docker-Instance"
  }
}

resource "aws_security_group" "main" {
  name        = "security-group-docker"
  description = "security group for docker instance"
}

resource "aws_security_group_rule" "docker-sg-ingress" {
  security_group_id = aws_security_group.main.id
  description       = "allow ingress traffic ssh allowed"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "docker-sg-egress" {
  security_group_id = aws_security_group.main.id
  description       = "egress-traffic"

  type        = "egress"
  protocol    = "-1"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
}

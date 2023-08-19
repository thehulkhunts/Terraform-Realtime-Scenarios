resource "aws_security_group" "ec2-sg" {
   vpc_id = var.vpc_id
   name = "ec2-security-group"
}

resource "aws_security_group" "alb-sg" {
   vpc_id = var.vpc_id
   name = "alb-security-group"
}

resource "aws_security_group_rule" "ingress-alb" {
    type  = "ingress"
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    from_port = 80
    to_port = 80
    prefix_list_ids = []
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.alb-sg.id
    
    
}


resource "aws_security_group_rule" "ingress-ec2-port" {
    type  = "ingress"
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    security_group_id = aws_security_group.ec2-sg.id
    source_security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "egress-alb" {
    type  = "egress"
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    security_group_id = aws_security_group.alb-sg.id
    source_security_group_id = aws_security_group.ec2-sg.id
}

resource "aws_launch_template" "template-ec2" {
    name = "ec2-template-launch"
    image_id = var.os
    vpc_security_group_ids = ["${aws_security_group.ec2-sg.id}"]
}

resource "aws_lb_target_group" "asg-tg" {
    name = "target-group-asg"
    vpc_id = var.vpc_id
    port = 80
    protocol = "HTTP"

     health_check {

          enabled             = true
          port                = 80
          interval            = 30
          protocol            = "HTTP"
          path                = "/health"
          healthy_threshold   = 3
          unhealthy_threshold = 3
  }

}

resource "aws_autoscaling_group" "asg-group" {
   name = "autoscaing-group"
   min_size = 2
   max_size = 4

   health_check_type = "EC2"

   vpc_zone_identifier = [var.pvt-subnet-03,
   var.pvt-subnet-04]

   target_group_arns = [aws_lb_target_group.asg-tg.arn]

   mixed_instances_policy {
     launch_template {
       launch_template_specification {
         launch_template_id = aws_launch_template.template-ec2.id

       }
       override {
         instance_type = "t2.medium"
       }
     }
   }
}

#To dynamically scale your auto-scaling group, you need to define a policy

resource "aws_autoscaling_policy" "asg-policy" {
   name = "asg-policy"
   autoscaling_group_name = aws_autoscaling_group.asg-group.name
   policy_type = "TargetTrackingScaling"

   estimated_instance_warmup = 300

   target_tracking_configuration {
     predefined_metric_specification {
       predefined_metric_type = "ASGAverageCPUUtilization"
     }
     target_value = 25.0
   }
}

resource "aws_lb" "load-balancer" {
   name = "loadbalancer-for-ASG"
   internal = false
   load_balancer_type = "application"
   security_groups = [aws_security_group.alb-sg.id]

   subnets = [var.subnet-01,
   var.subnet-02]

}

resource "aws_lb_listener" "alb-listner" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg-tg.arn

  }
}
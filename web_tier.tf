#Frontend
######### Create an EC2 Auto Scaling Group - web ############
resource "aws_autoscaling_group" "three-tier-web-asg" {
  name                 = "three-tier-web-asg"
  launch_configuration = aws_launch_configuration.three-tier-web-lconfig.id
  vpc_zone_identifier  = [aws_subnet.three-tier-pub-sub-1.id, aws_subnet.three-tier-pub-sub-2.id,aws_subnet.three-tier-pub-sub-3.id]
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2
}

###### Create a launch configuration for the EC2 instances #####
resource "aws_launch_configuration" "three-tier-web-lconfig" {
  name_prefix                 = "three-tier-web-lconfig"
  image_id                    = "ami-0230bd60aa48260c6"
  instance_type               = "t2.micro"
  key_name                    = "three-tier-web-asg-kp"
  security_groups             = [aws_security_group.three-tier-ec2-asg-sg.id]
  user_data                   = <<-EOF
                                #!/bin/bash

                                # Update the system
                                sudo yum -y update

                                # Install Apache web server
                                sudo yum -y install httpd

                                # Start Apache web server
                                sudo systemctl start httpd.service

                                # Enable Apache to start at boot
                                sudo systemctl enable httpd.service
                                EOF
  associate_public_ip_address = true                            
}                                

# Create Load balancer - web tier
resource "aws_lb" "three-tier-web-lb" {
  name               = "three-tier-web-lb"
  internal           = true
  load_balancer_type = "application"
  
  security_groups    = [aws_security_group.three-tier-alb-sg-1.id]
  subnets            = [aws_subnet.three-tier-pub-sub-1.id, aws_subnet.three-tier-pub-sub-2.id]

  tags = {
    Environment = "three-tier-web-lb"
  }
}

# create load balancer larget group - web tier

resource "aws_lb_target_group" "three-tier-web-lb-tg" {
  name     = "three-tier-web-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.three-tier-vpc.id

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Create Load Balancer listener - web tier
resource "aws_lb_listener" "three-tier-web-lb-listner" {
  load_balancer_arn = aws_lb.three-tier-web-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.three-tier-web-lb-tg.arn
  }
}

# Register the instances with the target group - web tier
resource "aws_autoscaling_attachment" "three-tier-web-asattach" {
  autoscaling_group_name = aws_autoscaling_group.three-tier-web-asg.name
  lb_target_group_arn   = aws_lb_target_group.three-tier-web-lb-tg.arn
  
}
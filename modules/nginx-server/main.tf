## - Security Group for nginx server -- ##
resource "aws_security_group" "nginx-sg" {
  vpc_id = var.vpc
  name   = "nginx-sg"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.internetCIDR]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.internetCIDR]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.internetCIDR]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id] # only allows traffic initated from the alb
  }
}

# This will curl icanhazip to retrieve your current public IP address, this will be used for the SG settings below so the nginx
# is only visible to you. 
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

## - Launch template for nginx Server -- ##
resource "aws_launch_template" "nginx-launch-template" {
  name_prefix            = "nginx-launch-template"
  image_id               = var.ami
  instance_type          = var.instanceType
  key_name               = var.keypair
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  user_data              = filebase64("${path.module}/bootstrap.sh")
}

## - Autoscaling Group for nginx server -- ##
resource "aws_autoscaling_group" "nginx-asg" {
  desired_capacity    = var.desiredCapacity
  max_size            = var.maxSize
  min_size            = var.minSize
  vpc_zone_identifier = [var.subnet1, var.subnet2]
  target_group_arns   = [aws_lb_target_group.nginx-tg.arn]
  launch_template {
    id      = aws_launch_template.nginx-launch-template.id
    version = "$Latest"
  }
}

## - Security Group for the ALB  -- ##
resource "aws_security_group" "alb-sg" {
  name        = "nginx-alb-sg"
  description = "Open necessary ports for the nginx ALB"
  vpc_id      = var.vpc # default vpc has already been created

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.internetCIDR]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.internetCIDR]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.internetCIDR]
  }
}

## - Nginx appliction load balancer -- ##
resource "aws_lb" "nginx-alb" {
  name            = "nginx-alb"
  security_groups = [aws_security_group.alb-sg.id]
  subnets         = [var.subnet1, var.subnet2]
}

## - Load balancer target group -- ##
resource "aws_lb_target_group" "nginx-tg" {
  name     = "nginx-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc
}

## - HTTPS listener with ssl  certificate -- ##
resource "aws_lb_listener" "alb-listener-https" {
  load_balancer_arn = aws_lb.nginx-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificateARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tg.arn
  }
}

## - Listener to redirect any 80 requests to 443 -- ##
resource "aws_lb_listener" "redirect-to-https" {
  load_balancer_arn = aws_lb.nginx-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
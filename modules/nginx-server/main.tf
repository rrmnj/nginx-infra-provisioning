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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] # only allows traffic from my ip
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] # only allows traffic from my ip
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

  launch_template {
    id      = aws_launch_template.nginx-launch-template.id
    version = "$Latest"
  }
}


#!/bin/bash
set -ex
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo docker run -p 80:80 -d nginxdemos/hello
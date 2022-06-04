/* */
// Global Configs
variable "region" {
  description = "Enter the AWS region to deploy resources"
  default     = "eu-west-1"
}
variable "profile" {
  description = "aws profile for CLI (where you store access / secret keys)"
  default     = "default"
}
/* ------- */
/* Infrastructure Variables */
variable "vpcCIDR" {
  description = "CIDR block for the VPC. Default is 10.0.0.0/16"
  default     = ""
}

variable "subnet1" {
  type = object({
    cidr = string
    az   = string
  })
  description = "Enter the 1st subnet's CIDR and AZ range - default is 10.0.1.0/24, eu-west-1a"

}
variable "subnet2" {
  type = object({
    cidr = string
    az   = string
  })
  description = "Enter the 2nd subnet's CIDR and AZ range - default is 10.0.1.0/24, eu-west-1a"
}
/* Microservice Variables */
variable "ami" {
  default     = "ami-0c1bc246476a5572b"
  description = "AMI for the webserver - default is Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type  to stay in AWS free tier."
}
variable "instanceType" {
  default     = "t2.micro"
  description = "Instance type for webserver - default is t2.micro to stay in AWS free tier."
}
variable "keypair" {
  default     = "private"
  description = "Keypair to SSH into nginx server - please note, port 22 is blocked by default - this would need to be open in the microservice SG."
}
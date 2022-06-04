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
/* ------- */
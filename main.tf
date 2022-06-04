/*
This is the 'main' Terraform file. It calls all of our modules in order to
bring up the whole infrastructure

  Please note -- All the variables are set in the 'terraform.tfvars' file in this directory.
  Please use variables.tf to define variables but use 'terraform.tfvars' to assign values to variables. 
  ** Variable validation is handled within each indvidual module. 
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = var.profile
}

module "infrastructure" {
  source = "./modules/infrastructure"
  /* -- Mandatory Parameters -- */
  vpcCIDR = var.vpcCIDR # define a CIDR range for the VPC 
  subnet1 = var.subnet1 # define a cidr / az for subnet 1
  subnet2 = var.subnet2 # define a cidr / az for subnet 2
  /* -- Optional Parameters -- */
  # allocatePublicIP = #  bool - allocate a public IP to each EC2 created? Default is true. 
}
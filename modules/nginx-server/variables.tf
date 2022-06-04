variable "keypair" {
  description = "Keypair to SSH into microservice - please note, port 22 is blocked by default - this would need to be open in the SG."
}

variable "ami" {
  description = "AMI for the microservice - default is Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type  to stay in AWS free tier."

  validation {
    condition     = length(var.ami) > 4 && substr(var.ami, 0, 4) == "ami-"
    error_message = "The ami value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "instanceType" {
  type        = string
  description = "Instance type for microservice - default is t2.micro to stay in AWS free tier."
}
variable "vpc" {
  type        = string
  description = "Please enter the VPC ID where the microservice will be deployed"
}
variable "subnet1" {
  type        = string
  description = "Please enter the Subnet 1 ID"

}
variable "subnet2" {
  type        = string
  description = "Please enter the Subnet 2 ID"
}

variable "internetCIDR" {
  default     = "0.0.0.0/0"
  description = "The CIDR block used for open communication to the internet."
}

variable "desiredCapacity" {
  type        = number
  description = "Enter the desired number of nginx nodes for autoscaling."
  validation {
    condition     = var.desiredCapacity <= 10
    error_message = "Desired node scaling cannot exceed 10 (to avoid costly accidents!)."
  }
}

variable "minSize" {
  type        = number
  description = "Enter the minimum number of nginx nodes for autoscaling."
}

variable "maxSize" {
  type        = number
  description = "Enter the maximum number of nginx nodes for autoscaling."
  validation {
    condition     = var.maxSize <= 10
    error_message = "Maximum node scaling cannot exceed 10 (to avoid costly accidents!)."
  }
}

variable "certificateARN" {
  description = "Please enter the ARN of a valid SSL certificate that has been uploaded to ACM."
}

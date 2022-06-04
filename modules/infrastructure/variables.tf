variable "internetCIDR" {
  default     = "0.0.0.0/0"
  description = "The CIDR block used for open communication to the internet."
}
variable "vpcCIDR" {
  description = "Enter a valid CIDR block for the VPC"
}

variable "allocatePublicIP" {
  default     = true
  type        = bool
  description = "Should a public IP be allocated to the EC2 created as part of this module? true/false - default true"
}

variable "subnet1" {
  type = object({
    cidr = string
    az   = string
  })
  description = "Enter the 1st subnet's CIDR and AZ range - default is 10.0.1.0/24, eu-west-1a"

  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.subnet1.az))
    error_message = "Must be a valid AWS Region name."
  }
  validation {
    condition     = can(cidrhost(var.subnet1.cidr, 32))
    error_message = "Must be a valid IPv4 CIDR."
  }
}

variable "subnet2" {
  type = object({
    cidr = string
    az   = string
  })
  description = "Enter the 2nd subnet's CIDR and AZ range default is 10.0.2.0/24, eu-west-1b"
  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.subnet2.az))
    error_message = "Must be a valid AWS Region name."
  }
  validation {
    condition     = can(cidrhost(var.subnet2.cidr, 32))
    error_message = "Must be a valid IPv4 CIDR."
  }

}
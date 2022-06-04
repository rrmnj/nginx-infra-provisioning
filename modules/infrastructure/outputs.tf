output "vpc-id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC created by the infrastructure module."
}

output "subnet1-id" {
  value       = aws_subnet.subnet1.id
  description = "The ID of the first subnet created by the infrastructure module."
}

output "subnet2-id" {
  value       = aws_subnet.subnet2.id
  description = "The ID of the second subnet created by the infrastructure module."
}
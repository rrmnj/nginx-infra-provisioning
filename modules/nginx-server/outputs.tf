output "alb-dns" {
  value       = aws_lb.nginx-alb.dns_name
  description = "The DNS name of the ALB."
}
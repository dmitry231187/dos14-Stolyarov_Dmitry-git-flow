output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.main.id
}

output "vpc_public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "vpc_private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

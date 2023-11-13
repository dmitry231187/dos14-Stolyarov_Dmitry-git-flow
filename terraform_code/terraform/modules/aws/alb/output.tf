output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.bpzb.dns_name
}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.bpzb.zone_id
}

output "lb_arn" {
  description = "The ARN of the load balancer (matches id)"
  value       = aws_lb.bpzb.arn
}

output "lb_sg_id" {
  description = "id of alb security group"
  value       = aws_security_group.alb.id
}

output "lb_tg" {
  description = "alb target group"
  value       = aws_lb_target_group.alb
}


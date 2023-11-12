output "certificate_arn" {
  description = "certificate for api.bpzb.smodata.net"
  value       = aws_acm_certificate_validation.api_bpzb.certificate_arn
}

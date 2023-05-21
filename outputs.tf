output "dns_name" {
  value = aws_lb.test.dns_name
}

output "listener" {
  value = try(aws_lb_listener.backend.*.arn[0], null )
}
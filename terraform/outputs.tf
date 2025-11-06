output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.morpheus.id
}

output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.morpheus.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.morpheus.public_dns
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.morpheus.public_ip}"
}

output "triton_http_endpoint" {
  description = "Triton HTTP endpoint"
  value       = "http://${aws_instance.morpheus.public_ip}:8000"
}

output "triton_grpc_endpoint" {
  description = "Triton gRPC endpoint"
  value       = "${aws_instance.morpheus.public_ip}:8001"
}

output "prometheus_endpoint" {
  description = "Prometheus endpoint"
  value       = "http://${aws_instance.morpheus.public_ip}:9090"
}

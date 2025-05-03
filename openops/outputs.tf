output "public_ip" {
  value = aws_instance.openops.public_ip
}

output "openops_url" {
  value = "http://${aws_instance.openops.public_ip}"
}

output "message" {
  value = "Instance will be provisioned after terraform apply. Confirm your SNS subscription to receive notification of deployment status."
}
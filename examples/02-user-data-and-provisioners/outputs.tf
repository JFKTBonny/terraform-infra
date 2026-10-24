output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "url" {
  description = "Web site URL"
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  description = "SSH into the server"
  value       = "ssh -i ${var.ssh_private_key_path} ubuntu@${aws_instance.web.public_ip}"
}

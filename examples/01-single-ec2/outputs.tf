output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "url" {
  description = "URL of the web server (wait 1–2 minutes for nginx to install)"
  value       = "http://${aws_instance.web.public_ip}"
}

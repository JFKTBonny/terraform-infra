output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "web_public_ip" {
  description = "Public IP of the web server"
  value       = module.web.public_ip
}

output "web_url" {
  description = "URL of the web server"
  value       = "http://${module.web.public_ip}"
}

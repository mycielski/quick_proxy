output "ssh_command" {
  description = "The SSH command to use to connect to the instance"
  value       = "ssh -i ${module.vm.key_file_path} ${module.vm.instance_username}@${module.vm.instance_public_ip}"
}

output "instance_address" {
  description = "The public IP address of the instance"
  value       = module.vm.instance_public_ip
}

output "proxy_port" {
  description = "The port to use to connect to the proxy"
  value       = 3128
}

output "proxy_username" {
  description = "The username to use to connect to the proxy"
  value       = var.proxy_username
  sensitive   = true
}

output "proxy_password" {
  description = "The password to use to connect to the proxy"
  value       = var.proxy_password
  sensitive   = true
}

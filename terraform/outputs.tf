output "k3s_server_public_ip" {
  description = "The public IP address of the k3s server."
  value       = aws_instance.k3s_server.public_ip
}

output "k3s_agent_public_ips" {
  description = "The public IP addresses of the k3s agents."
  value       = aws_instance.k3s_agents[*].public_ip
}

output "k3s_server_API_token" {
  description = "K3s server API token"
  value       = data.local_file.k3s_node_token_file.content
}
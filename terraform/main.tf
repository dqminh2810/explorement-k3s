# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create a new key pair for SSH access
resource "aws_key_pair" "k3s_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Create a security group
resource "aws_security_group" "k3s_sg" {
  name_prefix = "k3s-sg-"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow traffic from all nodes in the security group
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 instance for the k3s server
resource "aws_instance" "k3s_server" {
  ami           = "ami-0818ff4e4d072e0ec"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.k3s_key.key_name
  # user_data     = file("base-setup/install-k3s-server.sh")
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  tags = {
    Name = "k3s-server"
  }
}

# Create the EC2 instance(s) for the k3s agent(s)
resource "aws_instance" "k3s_agents" {
  count = var.agent_count
  ami           = "ami-0818ff4e4d072e0ec"
  instance_type = "t3.small"
  key_name      = aws_key_pair.k3s_key.key_name
  # user_data     = templatefile("base-setup/install-k3s-agent.sh", {
  #   k3s_url = "https://${aws_instance.k3s_server.private_ip}:6443",
  #   k3s_token = data.local_file.k3s_node_token_file.content
  # })
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  depends_on = [data.local_file.k3s_node_token_file]

  tags = {
    Name = "k3s-agent-${count.index + 1}"
  }
}

resource "null_resource" "setup-k3s-server" {
  depends_on = [aws_instance.k3s_server]
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting 60 seconds for SSH service to start..."
      sleep 60 

      export ANSIBLE_HOST_KEY_CHECKING=False
      ansible-playbook -i "${aws_instance.k3s_server.public_ip}," ./ansible/playbook-k3s-server.yaml \
        --user admin \
        --private-key ${var.private_key_path}
    EOT
  }
}

resource "null_resource" "get_k3s_token" {
  depends_on = [null_resource.setup-k3s-server]

  provisioner "local-exec" {
    command = "sleep 20 && ssh -v -o StrictHostKeyChecking=no -i ${var.private_key_path} admin@${aws_instance.k3s_server.public_ip} 'sudo head -c -1 /var/lib/rancher/k3s/server/node-token' > tmp/k3s_node_token"
  }
}

resource "null_resource" "setup-k3s-agents" {
  depends_on = [null_resource.get_k3s_token]
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting 60 seconds for SSH service to start..."
      sleep 60 

      export ANSIBLE_HOST_KEY_CHECKING=False
      ANSIBLE_HOSTS="${join(",", aws_instance.k3s_agents[*].public_ip)},"
      ansible-playbook -i $ANSIBLE_HOSTS ./ansible/playbook-k3s-agent.yaml \
        --user admin \
        --private-key ${var.private_key_path} \
        --extra-vars='{"k3s_url": "https://${aws_instance.k3s_server.private_ip}:6443", "k3s_token": "${data.local_file.k3s_node_token_file.content}"}'    
    EOT
  }
}

data "local_file" "k3s_node_token_file" {
  filename = "tmp/k3s_node_token"
  depends_on = [null_resource.get_k3s_token]
}
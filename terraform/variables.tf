variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "The AWS configuration profile to create AWS resources"
  type        = string
  default     = "aws-resources"
}

variable "key_name" {
  description = "The name of the SSH key pair to use."
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key file for SSH access."
  type        = string
}

variable "public_key_path" {
  description = "The path to the public key file for SSH access."
  type        = string
}

variable "agent_count" {
  description = "The number of k3s agent nodes to create."
  type        = number
  default     = 1
}
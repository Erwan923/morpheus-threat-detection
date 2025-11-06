variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type (GPU required)"
  type        = string
  default     = "g4dn.xlarge"
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "morpheus-threat-detection"
}

variable "key_name" {
  description = "SSH key pair name (must exist in AWS)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH"
  type        = string
  default     = "0.0.0.0/0"  # Change to your IP for security
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 100
}

variable "spot_instance" {
  description = "Use spot instance for cost savings"
  type        = bool
  default     = true
}

variable "spot_max_price" {
  description = "Maximum spot price (leave empty for on-demand price)"
  type        = string
  default     = "0.50"
}

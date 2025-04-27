variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  description = "Recommended type: t3.large (for Exploring OpenOps and building automations)"
  default = "t3.large"
}

variable "root_block_volume_size" {
  description = "Recommended size(in GB): 50 (for Exploring OpenOps and building automations) "
  default = 50
}

variable "key_name" {
  description = "Name of your AWS SSH key pair"
  default     = "openops-key"
}

variable "public_key_path" {
  description = "Absolute path to your public SSH key"
}

variable "sns_sbuscrition_email" {
  description = "Email id to receive notification after the deployment"
}
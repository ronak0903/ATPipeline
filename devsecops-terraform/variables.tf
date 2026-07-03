variable "region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "key_name" {
  default = "k8s"
}

variable "instance_type" {
  default = "t3.large"
}

variable "ecr_repo_name" {
  default = "devsecops-repo"
}

variable "ami_id" {
  type        = string
  description = "Hardcoded AMI ID to avoid DescribeImages permission issues"
  default     = "ami-0a7cf821b91bcccbc" # Ubuntu 22.04 LTS in ap-south-1 (Mumbai)
}

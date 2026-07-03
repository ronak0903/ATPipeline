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

variable "create_vpc" {
  type        = bool
  description = "Set to true to create a new VPC. Set to false to use the Default VPC."
  default     = false
}

variable "create_ecr" {
  type        = bool
  description = "Set to true to create a new ECR repo. Set to false if ECR creation is denied."
  default     = false
}

variable "create_sg" {
  type        = bool
  description = "Set to true to create a new Security Group. Set to false to use the Default Security Group."
  default     = false
}

variable "create_iam_profile" {
  type        = bool
  description = "Set to true to create a new IAM Role and Instance Profile. Set to false to skip or use a pre-existing one."
  default     = false
}

variable "existing_iam_profile" {
  type        = string
  description = "Name of a pre-existing IAM Instance Profile (e.g. LabInstanceProfile). Ignored if create_iam_profile is true."
  default     = ""
}

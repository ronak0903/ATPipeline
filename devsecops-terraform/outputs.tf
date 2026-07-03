# EC2
output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

# ECR
output "ecr_repository_url" {
  value = var.create_ecr ? module.ecr[0].repository_url : "ECR-creation-skipped"
}

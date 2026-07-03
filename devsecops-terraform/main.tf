data "aws_vpc" "default" {
  default = true
}

module "vpc" {
  count  = var.create_vpc ? 1 : 0
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
}

module "ecr" {
  count  = var.create_ecr ? 1 : 0
  source = "./modules/ecr"

  repo_name = var.ecr_repo_name
}

module "ec2" {
  source = "./modules/ec2"

  instance_type = var.instance_type
  key_name      = var.key_name
  ami_id        = var.ami_id
  region        = var.region

  # If create_vpc is false, pass null to let AWS automatically select the default subnet.
  # This avoids calling DescribeSubnets, which is blocked by SCP in restricted accounts.
  subnet_id = var.create_vpc ? module.vpc[0].public_subnet_id : null
  vpc_id    = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.default.id

  ecr_url   = var.create_ecr ? module.ecr[0].repository_url : ""

  create_sg            = var.create_sg
  create_iam_profile   = var.create_iam_profile
  existing_iam_profile = var.existing_iam_profile
}
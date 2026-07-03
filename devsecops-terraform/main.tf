data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
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

  subnet_id = var.create_vpc ? module.vpc[0].public_subnet_id : element(data.aws_subnets.default.ids, 0)
  vpc_id    = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.default.id

  ecr_url   = var.create_ecr ? module.ecr[0].repository_url : ""
}
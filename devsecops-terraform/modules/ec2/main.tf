data "aws_security_group" "default" {
  count  = var.create_sg ? 0 : 1
  vpc_id = var.vpc_id
  name   = "default"
}

resource "aws_security_group" "sg" {
  count  = var.create_sg ? 1 : 0
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role" {
  count = var.create_iam_profile ? 1 : 0
  name  = "ec2-ecr-role-devsecops"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  count      = var.create_iam_profile ? 1 : 0
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.create_iam_profile ? 1 : 0
  name  = "ec2-ecr-profile-devsecops"
  role  = aws_iam_role.ec2_role[0].name
}

resource "aws_instance" "devsecops" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [var.create_sg ? aws_security_group.sg[0].id : data.aws_security_group.default[0].id]

  iam_instance_profile = var.create_iam_profile ? aws_iam_instance_profile.ec2_profile[0].name : (var.existing_iam_profile != "" ? var.existing_iam_profile : null)

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "DevSecOps-Instance"
  }
}
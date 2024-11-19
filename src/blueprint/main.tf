
# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  name                 = var.vpc_name
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-1a"]
  public_subnets       = ["10.0.1.0/24"]
  private_subnets      = ["10.0.2.0/24"]
  enable_nat_gateway   = false
  enable_dns_support   = true
  enable_dns_hostnames = true

  public_route_table_tags = {
    Name = "public-rt"
  }

  private_route_table_tags = {
    Name = "private-rt"
  }

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_route" "public_custom_route" {
  route_table_id         = module.vpc.public_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc.igw_id
}

# resource "aws_route" "private_custom_route" {
#   route_table_id         = module.vpc.private_route_table_ids[0]
#   # destination_cidr_block = "10.0.0.0/16"
#   # nat_gateway_id         = module.vpc.nat_gateway_ids[0]
# }

# Public Security Group
resource "aws_security_group" "public_sg" {
  name   = "public_security_group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private Security Group
# resource "aws_security_group" "private_sg" {
#   name   = "private_security_group"
#   vpc_id = module.vpc.vpc_id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow SSH"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# EC2 Module | Public Instance
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(["nginx", "Jump"])

  name = "${each.key}-instance"

  instance_type = "t2.micro"
  ami = "ami-0866a3c8686eaeeba"
  key_name = "nginx-key"
  monitoring = false
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "ec2_public2" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(["ghost"])

  name = "${each.key}-instance"

  instance_type = "t2.micro"
  ami = "ami-0866a3c8686eaeeba"
  key_name = "nginx-key"
  monitoring = false
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
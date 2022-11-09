name                = "backend"
availability_zones  = ["us-east-1a", "us-east-1b"]
private_subnets     = ["10.0.0.0/20", "10.0.32.0/20"]
public_subnets      = ["10.0.16.0/20", "10.0.48.0/20"]
aws_ecr_repository_url ="ghcr.io/ikermenka1/phpfpm:sha-76b12f6"
environment            = "dev"
cidr                   = "10.0.0.0/16"
vpc_cidr               = "10.0.16.0/20"

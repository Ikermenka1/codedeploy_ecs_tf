provider "aws" {
shared_credentials_file = "$HOME/.aws/credentials"
region     = var.aws-region
version    = "~> 3.37.0"
}

terraform {
backend "s3" {
bucket  = "configfilebucket"
key     = "testterraform.tfstate"
region  = "ap-south-1"
}
}
module "vpc" {
source             = "./codedeploy_ecs_tf/vpc"
name               = var.name
cidr               = var.cidr
private_subnets    = var.private_subnets
public_subnets     = var.public_subnets
availability_zones = var.availability_zones
environment        = var.environment
}
module "security_groups" {
source         = "./codedeploy_ecs_tf/security-groups"
name           = var.name
vpc_id         = module.vpc.id
environment    = var.environment
container_port = var.container_port
vpc_cidr       = module.vpc.cidr
}
module "alb" {
source              = "./codedeploy_ecs_tf/alb"
name                = var.name
vpc_id              = module.vpc.id
subnets             = module.vpc.public_subnets
environment         = var.environment
alb_security_groups = [module.security_groups.alb]
#alb_tls_cert_arn    = var.tsl_certificate_arn
health_check_path   = var.health_check_path
}
module "ecs" {
source                      = "./codedeploy_ecs_tf/ecs"
name                        = var.name
environment                 = var.environment
region                      = var.aws-region
subnets                     = module.vpc.private_subnets
aws_alb_target_group_arn    = module.alb.aws_alb_target_group
aws_alb_listener            = module.alb.aws_alb_listener
ecs_service_security_groups = [module.security_groups.ecs_tasks]
container_port              = var.container_port
container_cpu               = var.container_cpu
container_memory            = var.container_memory
service_desired_count       = var.service_desired_count
tag                         = var.build_tag
container_environment = [
{ name = "LOG_LEVEL",
value = "DEBUG" },
{ name = "PORT",
value = var.container_port }
]
container_image = var.aws_ecr_repository_url
}
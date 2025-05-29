
module "s3" {
    source = "./modules/s3" 
    project_name = var.project_name
    s3_bucket_name = var.s3_bucket_name
}

module "vpc" {
  source       = "./modules/vpc"
  region       = var.region
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  pri_sub_cidr = var.pri_sub_cidr
  availability_zone = var.availability_zone
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "security-group" {
  source       = "./modules/security-group"
  project_name         = var.project_name
  vpc_id       = module.vpc.vpc_id
  pri_sub_cidr = var.pri_sub_cidr
}

module "ec2" {
  source               = "./modules/ec2"
  keyname              = var.keyname
  pri_sub_id           = module.vpc.pri_sub_id
  project_name         = var.project_name
  ec2_sg_id            = module.security-group.ec2_sg_id
  iam_instance_profile = module.iam.iam_instance_profile
  s3-id                = module.s3.s3_bucket_id
}

module "endpoint" {
  source             = "./modules/endpoint"
  region             = var.region
  pri_sub_id         = module.vpc.pri_sub_id
  vpc_id             = module.vpc.vpc_id
  ssm_https_sg_id    = module.security-group.ssm_https_sg_id
  pri_route_table_id = module.vpc.pri_route_table_id
  project_name         = var.project_name
}


/*
module "iam-cloudwatch" {
  source       = "./modules/iam-cloudwatch"
  project_name = var.project_name
}

module "ssh_command" {
  source        = "./your-null-resource-module"
  instance_ip   = "54.12.34.56"
  ssh_key_path  = "~/.ssh/your-key.pem"
}

*/
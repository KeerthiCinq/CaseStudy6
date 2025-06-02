terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider

data "aws_secretsmanager_secret_version" "aws_creds" {
  secret_id = "terraform/aws/creds"
}

locals {
  creds = jsondecode(data.aws_secretsmanager_secret_version.aws_creds.secret_string)
}

provider "aws" {
  alias  = "with_secrets"
  region = "us-east-1"

  access_key = local.creds.aws_access_key_id
  secret_key = local.creds.aws_secret_access_key
}
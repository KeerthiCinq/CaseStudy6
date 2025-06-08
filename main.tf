
module "s3" {
  source         = "./modules/s3"
  project_name   = var.project_name
  s3_bucket_name = var.s3_bucket_name
}

module "vpc" {
  source            = "./modules/vpc"
  region            = var.region
  project_name      = var.project_name
  vpc_cidr          = var.vpc_cidr
  pri_sub_cidr      = var.pri_sub_cidr
  availability_zone = var.availability_zone
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "security-group" {
  source       = "./modules/security-group"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  pri_sub_cidr = var.pri_sub_cidr
}

module "ec2" {
  source               = "./modules/ec2"
  keyname              = var.keyname
  pri_sub_id           = module.vpc.pri_sub_id
  project_name         = var.project_name
  ec2_sg_id            = module.security-group.ec2_sg_id
  iam_instance_profile = module.iam.instance_profile_name
  s3-id                = module.s3.s3_bucket_id
}

module "endpoint" {
  source             = "./modules/endpoint"
  region             = var.region
  pri_sub_id         = module.vpc.pri_sub_id
  vpc_id             = module.vpc.vpc_id
  ssm_https_sg_id    = module.security-group.ssm_https_sg_id
  pri_route_table_id = module.vpc.pri_route_table_id
  project_name       = var.project_name
}


## Cloud trail creation
data "aws_caller_identity" "current" {}

# Create S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "my-cloudtrail-logs-bucket-${data.aws_caller_identity.current.account_id}"
  
}

# S3 bucket policy allowing CloudTrail to write logs
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudTrailGetBucketACL",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:GetBucketAcl",
        Resource  = aws_s3_bucket.cloudtrail_bucket.arn,
      },
      {
        Sid       = "AllowCloudTrailPutObject",
        Effect    = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.cloudtrail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Create CloudTrail trail
resource "aws_cloudtrail" "main" {
  name                          = "ec2-s3-activity-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type            = "All"
    include_management_events  = true

    # Optional: restrict  S3 resources
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
}

# Optional: IAM role and policy for reading CloudTrail logs and events
resource "aws_iam_role" "cloudtrail_reader_role" {
  name = "CloudTrailLogsReaderRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "cloudtrail_read_policy" {
  name        = "CloudTrailLogsReadPolicy"
  description = "Policy to read CloudTrail logs from S3 and lookup CloudTrail events"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.cloudtrail_bucket.arn,
          "${aws_s3_bucket.cloudtrail_bucket.arn}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
          "cloudtrail:LookupEvents"
        ],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_read_policy" {
  role       = aws_iam_role.cloudtrail_reader_role.name
  policy_arn = aws_iam_policy.cloudtrail_read_policy.arn
}

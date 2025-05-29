
# 1. Create IAM Policy
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "CloudWatchLogsWritePolicy"
  description = "Allows writing logs to CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      }
    ]
  })
}

# 2. Create IAM Role
resource "aws_iam_role" "cloudwatch_logs_role" {
  name = "cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 3. Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.cloudwatch_logs_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}


# 4. Add instance profile
resource "aws_iam_instance_profile" "iam_profile" {
  name = "cloudwatch_iam_profile"
  role = aws_iam_role.cloudwatch_logs_role.name
  tags = {
    Name = "${var.project_name}"
  }
}

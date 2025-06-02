data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach a Managed Policy to the Role
resource "aws_iam_role_policy_attachment" "ssm_managed_ec2" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# You can attach multiple policies similarly
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Create IAM Policy for cloudwatch logs
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


# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}


# Add instance profile
resource "aws_iam_instance_profile" "my_instance_profile" {
  name = "cloudwatch_agent_instance_profile"
  role = aws_iam_role.role.name
  tags = {
    Name = "${var.project_name}"
  }
}

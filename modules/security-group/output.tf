output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}
output "ssm_https_sg_id" {
  value = aws_security_group.ssm_https_sg.id
}
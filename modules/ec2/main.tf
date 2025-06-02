
resource "aws_instance" "ec2" {
  associate_public_ip_address = false
  subnet_id                   = var.pri_sub_id
  instance_type               = "t2.micro"
  ami                         = var.ami
  vpc_security_group_ids      = [var.ec2_sg_id]
  iam_instance_profile = var.iam_instance_profile
  user_data            = data.template_file.user_data.rendered

  key_name = var.keyname
  tags = {
    Name = "ec2-${var.project_name}"
  }
  
}


data "template_file" "user_data" {
  template = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    yum install httpd -y
    echo "Listing all files in s3://$S3_BUCKET/"

    aws s3 ls "s3://var.s3-id/" --recursive
    aws s3 cp s3://var.s3-id/index.html /var/www/html/index.html
    systemctl start httpd
    systemctl enable httpd

    sudo yum install awslogs
    sudo service awslogsd start
    sudo systemctl enable awslogsd
    
  EOF
}
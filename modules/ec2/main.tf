
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
    
    sudo yum update -y
    sudo yum install httpd -y
    sudo apt install unzip

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    echo "Listing all files in s3://$S3_BUCKET/"

    aws s3 ls "s3://var.s3-id/" --recursive
    
    sudo systemctl start httpd
    sudo systemctl enable httpd
   #Install cloudwatch agent
    sudo yum install -y amazon-cloudwatch-agent
    #Create log configuration file
    sudo nano /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

     # Create a config file using heredoc
sudo bash -c 'cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/dnf.log",
            "log_group_name": "ec2-system-logs",
            "log_stream_name": "{instance_id}/messages",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
EOT'

#Start the agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s
        
  EOF
}

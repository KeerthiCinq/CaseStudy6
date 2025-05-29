variable "instance_ip" {
  description = "Public IP of the existing EC2 instance"
  type        = string
}

variable "ssh_key_path" {
  description = "Path to your private SSH key"
  type        = string
}

resource "null_resource" "ssh_into_ec2" {
  provisioner "local-exec" {
    command = <<EOT
    ssh -o StrictHostKeyChecking=no -i "${var.ssh_key_path}" ubuntu@${var.instance_ip} "aws ec2 associate-iam-instance-profile \
  --instance-id i-0123456789abcdef0 \
  --iam-instance-profile Name=YourInstanceProfileName"
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}



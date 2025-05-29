locals {
 services = {
   "ec2messages" : {
     "name" : "com.amazonaws.${var.region}.ec2messages"
   },
   "ssm" : {
     "name" : "com.amazonaws.${var.region}.ssm"
   },
   "ssmmessages" : {
     "name" : "com.amazonaws.${var.region}.ssmmessages"
   }
 }
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
 for_each = local.services
 vpc_id    = var.vpc_id
 service_name        = each.value.name
 vpc_endpoint_type   = "Interface"
 security_group_ids  = [var.ssm_https_sg_id]
 private_dns_enabled = true
 ip_address_type     = "ipv4"
 subnet_ids          = [var.pri_sub_id]

tags = {
    Name = "interface-endpoint-${var.project_name}"
  }

}

resource "aws_vpc_endpoint" "gateway_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  route_table_ids   = [var.pri_route_table_id] 
  tags = {
    Name = "gateway-endpoint-s3-${var.project_name}"
  }
}
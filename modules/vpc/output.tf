
output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "pri_sub_id" {
  value = aws_subnet.pri_sub.id
}
output "pri_route_table_id" {
  value = aws_route_table.pri_route_table.id
}
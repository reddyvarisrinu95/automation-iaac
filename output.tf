
output "zones" {
  value = data.aws_availability_zones.available.names

}



output  "igwid"  {
    value = aws_internet_gateway.igw.id
}
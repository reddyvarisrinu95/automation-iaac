
data  "aws_availability_zones" "available" {
  state = "available"

}



resource "aws_vpc" "vpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"


  tags = {
    Name = "dev-vpc"
    terraform = "true"

  }
}

#create internet_gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "dev-igw"
  }

  depends_on = [
    aws_vpc.vpc
  ]
}


#create subnets

resource "aws_subnet" "public1" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.pub_cidr ,count.index)
  map_public_ip_on_launch = "true"
  availability_zone = element(data.aws_availability_zones.available.names ,count.index)

  tags = {
    Name = "dev-publicsubnet-${count.index+1}"
  }
}



resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.private_cidr ,count.index)
 # map_public_ip_on_launch = "true"
  availability_zone = element(data.aws_availability_zones.available.names ,count.index)

  tags = {
    Name = "dev-privatesubnet-${count.index+1}"
  }
}



resource "aws_subnet" "data" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = element(var.data_cidr ,count.index)
  #map_public_ip_on_launch = "true"
  availability_zone = element(data.aws_availability_zones.available.names ,count.index)

  tags = {
    Name = "dev-datasubnet-${count.index+1}"
  }
}


#create eip

resource "aws_eip" "eip" {
  
  vpc  = true
  tags = {
    Name = "vpc-eip"
  }
}


#create natgw


resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1[0].id

  tags = {
    Name = "dev-gw NAT"
  }

  
  depends_on = [
    aws_eip.eip
  ]
}


#create public route tables

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "dev-public-route"
  }
}

#create private route tables

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }


  tags = {
    Name = "dev-private-route"
  }
}


#route table association


 resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public1[*].id)
  subnet_id = element(aws_subnet.public1[*].id ,count.index)
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count = length(aws_subnet.public1[*].id)
  subnet_id = element(aws_subnet.private[*].id ,count.index)
  route_table_id = aws_route_table.private.id
}



resource "aws_route_table_association" "data" {
  count = length(aws_subnet.public1[*].id)
  subnet_id = element(aws_subnet.data[*].id ,count.index)
  route_table_id = aws_route_table.private.id
}


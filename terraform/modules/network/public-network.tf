resource "aws_vpc" "vpc" {

  cidr_block = var.vpc_cidr_block
  tags = {
    Name ="master-vpc1" 
  }
}

resource "aws_subnet" "public_subnet" {
  for_each = var.public_subnet_credentials

  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone = each.value.availability_zone
  cidr_block = each.value.cidr_block
  tags = {
    Name="public-subnet-${each.key}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name="internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name= "public_route_table"
    }
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  depends_on = [ aws_internet_gateway.igw ]
}


resource "aws_route_table_association" "this" {
  for_each = aws_subnet.public_subnet
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = each.value.id
}





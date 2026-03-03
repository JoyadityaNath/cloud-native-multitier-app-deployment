resource "aws_subnet" "private_subnet" {
  for_each = var.private_subnet_credentials

  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name="private-subnet-${each.key}"
  }
}


resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public_subnet

  
  subnet_id = each.value.id
  allocation_id = aws_eip.this[each.key].id
  depends_on = [aws_eip.this]
  
  tags = {
    Name = "nat-gateway-${each.key}"
  }
}

resource "aws_eip" "this" {
  for_each = aws_subnet.public_subnet

  domain="vpc"
}

resource "aws_route_table" "private_route_table" {
    for_each = aws_nat_gateway.nat

    vpc_id = aws_vpc.vpc.id
    tags = {
      Name= "private_route_table_${each.key}"
    }
}

resource "aws_route" "private_route" {
  for_each = aws_nat_gateway.nat

  route_table_id = aws_route_table.private_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = each.value.id
}


resource "aws_route_table_association" "rta" {
  for_each = aws_subnet.private_subnet
  route_table_id = aws_route_table.private_route_table[each.key].id
  subnet_id = each.value.id
}


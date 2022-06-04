# create the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpcCIDR
  tags = {
    Name = "Custom VPC"
  }
}

# create the Subnet which will automatically map a public IP
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet1.cidr
  availability_zone       = var.subnet1.az
  map_public_ip_on_launch = var.allocatePublicIP
  tags = {
    Name = "Custom Subnet 1"
  }
}

# create the Subnet which will automatically map a public IP
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet2.cidr
  availability_zone       = var.subnet2.az
  map_public_ip_on_launch = var.allocatePublicIP
  tags = {
    Name = "Custom Subnet 2"
  }
}

# create NACL
resource "aws_network_acl" "nacl" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  tags = {
    Name = "Custom NACL"
  }
  # 443 for load balancer https
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.internetCIDR
    from_port  = 443
    to_port    = 443
  }

  #  ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.internetCIDR
    from_port  = 1024
    to_port    = 65535
  }


  #  outbound 80 for http packages (yum  fails when this rule isn't open)
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.internetCIDR
    from_port  = 80
    to_port    = 80
  }

  #  outbound 443 for https packages (yum fails when this rule isn't open)
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.internetCIDR
    from_port  = 443
    to_port    = 443
  }

  # ephemeral ports 
  egress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = var.internetCIDR
    from_port  = 1024
    to_port    = 65535
  }
}

# Create IGW and associate it with the VPC
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Custom IGW"
  }

}
# Create the Route Table & associate it with VPC
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Custom Route Table"
  }
}

#  Allow VPC to communicate to internet 
resource "aws_route" "internet-route" {
  route_table_id         = aws_route_table.route-table.id
  destination_cidr_block = var.internetCIDR
  gateway_id             = aws_internet_gateway.IGW.id
}

# associate route table with subnet 1
resource "aws_route_table_association" "route-table-assoc-1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route-table.id
}

# associate route table with subnet 2
resource "aws_route_table_association" "route-table-assoc-2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route-table.id
}
provider "aws" {
  region = "ap-southeast-1"
  //shared_credentials_file = ".awscredentials/accessKeys.csv"
}
data "aws_availability_zones" "available" {
  state = "available"
}
//Creating a new VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "2020FebVPC"
  }
}
// Create a IGW 
resource "aws_internet_gateway" "gw"{
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "2020FebIGW"
  }
} 
// Create public route table
resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "2020FebPublicRouteTable"
  }
}
// Create a private route table
resource "aws_default_route_table" "private_route" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"
  route {
    nat_gateway_id = "${aws_nat_gateway.natgw.id}"  //Attach NAT gateway to route table
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "PrivateRT"}
}
//Create Public Subnets
resource "aws_subnet" "public_subnet" {
  count = 2
  cidr_block = "${var.public_cidrs[count.index]}"
  vpc_id = "${aws_vpc.main.id}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}" 
  tags = {
    Name = "2020FebPublicSubet.${count.index + 1}"
  }
}

//Create Private Subnets
resource "aws_subnet" "private_subnet" {
  count =  2
  cidr_block = "${var.private_cidrs[count.index]}"
  vpc_id = "${aws_vpc.main.id}" 
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}" 
  tags = {
    Name = "2020FebPrivateSubnet.${count.index + 1}"
  }
}
//Create a route table association
# Associate public subnet with public route table
resource "aws_route_table_association" "public_subnet_assoc" {
    count = 2
    route_table_id = "${aws_route_table.public_route.id}"  
    subnet_id = "${aws_subnet.public_subnet.*.id[count.index]}"
    depends_on = ["aws_route_table.public_route", "aws_subnet.public_subnet"]
}

// Associate private subnet with private route table
resource "aws_route_table_association" "private_subnet_assoc" {
  count = 2
  route_table_id = "${aws_default_route_table.private_route.id}"
  subnet_id = "${aws_subnet.private_subnet.*.id[count.index]}"
  depends_on = ["aws_default_route_table.private_route", "aws_subnet.private_subnet"]
}

// Create a SG
resource "aws_security_group" "Feb2020SG" {
  name = "Feb2020SG"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "allow-SSH" {
  from_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.Feb2020SG.id}"
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow-HTTP" {
  from_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.Feb2020SG.id}"
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow-HTTPS" {
  from_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.Feb2020SG.id}"
  to_port = 443
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_outbound" {
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.Feb2020SG.id}"
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

//Create a Elastic IP address
resource "aws_eip" "EIP_address" {
  vpc = true
}
//Create a NAT gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.EIP_address.id}"
  subnet_id = "${aws_subnet.public_subnet.1.id}" //ID of the subnet in which to place the gateway
}








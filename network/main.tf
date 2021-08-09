#-------------VPC and Internet Gateway------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       =  { 
    Name = "${var.tags}-vpc" 
    }
}


resource "aws_internet_gateway" "opencard_igw" {
  vpc_id = aws_vpc.main.id
  tags   =  { 
    Name = "${var.tags}_igw" }
}

resource "aws_route_table" "opencard_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.opencard_igw.id
  }
  tags = { 
    Name = "${var.tags}-rt" }
}

#-------------Public Subnets and Routing----------------------------------------

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = { 
      Name = "public-sb${count.index + 1}" 
      }
}




resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.opencard_rt.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}


#--------------Private Subnets-------------------------

resource "aws_eip" "nat_ip" {
  count = length(var.private_subnet_cidrs)
  vpc = true
  tags = {
    Name = "nat-${var.tags}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat_ip[count.index].id
  subnet_id = aws_subnet.public_subnets[count.index].id
  tags = {
    Name = "${var.tags}-nat-gw"
  }
}
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags                    = { 
      Name = "private-sb${count.index + 1}" 
      }
}

resource "aws_route_table" "opencard_rt-private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }
  tags = { 
    Name = "${var.tags}-rt" 
    }

}
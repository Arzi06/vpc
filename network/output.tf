output "vpc_id" {
    value = aws_vpc.main.id
}

output "aws_intergetway" {
    value = aws_internet_gateway.opencard_igw.id
}

output "az_name" {
    value = data.aws_availability_zones.available.names[*]
}

output "public-subnet" {
    value = aws_subnet.public_subnets[*].id
}

output "private-subnet" {
    value = aws_subnet.private_subnets[*].id
}

# output "aws_netgetway" {
#     value = aws_nat_gateway.nat_gw.id
# }

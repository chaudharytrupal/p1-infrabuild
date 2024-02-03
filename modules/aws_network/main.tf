# Step 1 - Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}


# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    var.default_tags, {
      #Name = "${var.prefix}-vpc"
      Name = "VPC - ${var.envname}"
    }
  )
}


# Add provisioning of the public subnet in the VPC
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.default_tags, {
      Name = "${var.env}-${var.prefix}-public-subnet-${count.index+1}"
    }
  )
}

# Add provisioning of the private subnets in the custom VPC
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.default_tags, {
      Name = "${var.env}-${var.prefix}-private-subnet-${count.index+1}"
      Tier = "Private"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  count = var.env == "prod" ? 0 : 1
  vpc_id = aws_vpc.main.id

  tags = merge(var.default_tags,
    {
      "Name" = "${var.env}-${var.prefix}-igw"
    }
  )
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.env == "prod" ? [] : [1]
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw[0].id
    }
  }
  tags = {
    Name = "${var.env}-${var.prefix}-route-public-route_table"
  }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Route table to route add default gateway pointing to NAT Gateway (NATGW)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-${var.prefix}-route-private-route_table",
    Tier = "Private"
  }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
provider "aws" {
  region = "us-east-1"
}
# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../../modules/globalvars"
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = local.prefix
}

# Module to deploy basic networking 
module "vpc-staging" {
  source              = "../../../modules/aws_network"
  env                 = var.env
  vpc_cidr            = var.vpc_cidr
  public_cidr_blocks  = var.public_subnet_cidrs
  private_cidr_blocks = var.private_subnet_cidrs
  prefix              = local.name_prefix
  default_tags        = local.default_tags
  envname             = var.envname

}
#Create NAT GW
resource "aws_nat_gateway" "nat-gw" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  allocation_id = aws_eip.nat-eip.id
  subnet_id     = module.vpc-staging.public_subnet_ids[0]
  tags = {
    Name = "${var.env}-${var.prefix}-natgw"
  }

  depends_on = [module.vpc-staging.aws_internet_gateway]
}

# Create elastic IP for NAT GW
resource "aws_eip" "nat-eip" {
  vpc = true
  tags = {
    Name = "${var.env}-${var.prefix}-natgw"
  }

}

#Add route to NAT GW if we created public subnets
resource "aws_route" "private_route" {
  count                  = aws_nat_gateway.nat-gw != null ? 1 : 0
  route_table_id         = module.vpc-staging.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat-gw[count.index].id
}


data "terraform_remote_state" "prod" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "prod-acs730-assignment1-trupal" // Bucket from where to GET Terraform State
    key    = "prod-network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                      // Region where bucket created
  }
}

module "vpc_peering" {
  source              = "../../../modules/aws_peering"
  peer_vpc_id         = data.terraform_remote_state.prod.outputs.vpc_id
  vpc_id              = module.vpc-staging.vpc_id
  route_table_id      = module.vpc-staging.public_route_table_id
  peer_route_table_id = data.terraform_remote_state.prod.outputs.route_table_id
  local_cidr_block    = var.vpc_cidr
  peer_cidr_block     = data.terraform_remote_state.prod.outputs.vpc_cidr
}

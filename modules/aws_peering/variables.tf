variable "peer_vpc_id" {
  description = "VPC id for the peering connection"
}

variable "vpc_id" {
  description = "VPC id primary."
}

variable "route_table_id" {
  description = "Primary route table id"
}

variable "peer_route_table_id" {
  description = "Peering VPC route table id"
}

variable "local_cidr_block" {
  description = "CIDR block of the local VPC."
}

variable "peer_cidr_block" {
  description = "CIDR block of the peer VPC."
}
resource "aws_route" "peer_route_to_prod" {
  route_table_id = var.route_table_id
  destination_cidr_block = var.peer_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_route" "local_route" {
  route_table_id = var.peer_route_table_id
  destination_cidr_block = var.local_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_vpc_peering_connection" "vpc_peering" {
    peer_vpc_id = var.peer_vpc_id
    vpc_id = var.vpc_id
    auto_accept = true
}
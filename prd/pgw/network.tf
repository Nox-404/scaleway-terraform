###
# VPC
###
# Auto created by PGW

###
# Private Network
###
resource "scaleway_vpc_private_network" "pn" {
  name = "k8s-pgw-pn"
  # vpc_id = provisionned by the pgw
  region = var.region

  tags = ["terraform", "pgw"]
}


###
# Public Gateway
###
resource "scaleway_vpc_public_gateway_ip" "ip" {
  tags = ["terraform", "pgw"]
}

resource "scaleway_vpc_public_gateway" "pgw" {
  name = "k8s-pgw"
  type = "VPC-GW-S"

  ip_id = scaleway_vpc_public_gateway_ip.ip.id

  tags = ["terraform", "pgw"]
}

resource "scaleway_vpc_gateway_network" "net" {
  gateway_id         = scaleway_vpc_public_gateway.pgw.id
  private_network_id = scaleway_vpc_private_network.pn.id

  ipam_config {
    push_default_route = true
  }

  enable_masquerade = true
}

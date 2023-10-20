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

  ipv4_subnet {
    subnet = "172.16.4.0/22"
  }

  tags = ["terraform", "pgw"]
}


###
# Public Gateway
###
resource "scaleway_vpc_public_gateway_ip" "ip" {
  tags = ["terraform", "pgw"]
}

resource "scaleway_vpc_public_gateway_dhcp" "dhcp" {
  subnet             = "172.16.4.0/22"
  push_default_route = true
  push_dns_server    = true
}

resource "scaleway_vpc_public_gateway" "pgw" {
  name = "k8s-pgw"
  type = "VPC-GW-S"

  ip_id = scaleway_vpc_public_gateway_ip.ip.id

  tags = ["terraform", "pgw"]

  depends_on = [
    scaleway_vpc_public_gateway_ip.ip
  ]
}

resource "scaleway_vpc_gateway_network" "net" {
  gateway_id         = scaleway_vpc_public_gateway.pgw.id
  private_network_id = scaleway_vpc_private_network.pn.id

  enable_dhcp  = true
  cleanup_dhcp = true
  dhcp_id      = scaleway_vpc_public_gateway_dhcp.dhcp.id

  enable_masquerade = true

  depends_on = [
    scaleway_vpc_public_gateway.pgw,
    scaleway_vpc_private_network.pn,
    scaleway_vpc_public_gateway_dhcp.dhcp
  ]
}

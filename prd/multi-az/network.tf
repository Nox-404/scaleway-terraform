###
# VPC
###
resource "scaleway_vpc" "vpc" {
  name   = "k8s-multiaz-vpc"
  region = var.region

  tags = ["terraform", "multiaz"]
}

###
# Private Network
###
resource "scaleway_vpc_private_network" "pn" {
  name   = "k8s-multiaz-pn"
  vpc_id = scaleway_vpc.vpc.id
  region = var.region

  ipv4_subnet {
    subnet = "172.16.8.0/22"
  }

  tags = ["terraform", "multiaz"]

  depends_on = [
    scaleway_vpc.vpc
  ]
}

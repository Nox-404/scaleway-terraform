###
# VPC
###
resource "scaleway_vpc" "vpc" {
  name   = "k8s-default-vpc"
  region = var.region

  tags = ["terraform", "default"]
}

###
# Private Network
###
resource "scaleway_vpc_private_network" "pn" {
  name   = "k8s-default-pn"
  vpc_id = scaleway_vpc.vpc.id
  region = var.region

  tags = ["terraform", "default"]
}

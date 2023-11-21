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

  tags = ["terraform", "multiaz"]
}

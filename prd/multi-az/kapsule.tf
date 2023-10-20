###
# Placement Group
###
resource "scaleway_instance_placement_group" "pg_kapsule" {
  for_each = toset([
    "fr-par-1",
    "fr-par-2",
    "fr-par-3"
  ])

  name = "k8s-multiaz-${each.key}"
  zone = each.key

  policy_mode = "enforced"
  policy_type = "max_availability"

  tags = ["terraform", "multiaz"]
}

###
# Kapsule
###
resource "scaleway_k8s_cluster" "kapsule" {
  name = "k8s-${var.region}-multiaz"

  type    = "kapsule"
  version = "1.28"
  cni     = "cilium"

  private_network_id = scaleway_vpc_private_network.pn.id

  delete_additional_resources = true

  autoscaler_config {
    ignore_daemonsets_utilization = true
    balance_similar_node_groups   = true
  }

  auto_upgrade {
    enable                        = true
    maintenance_window_day        = "sunday"
    maintenance_window_start_hour = 2
  }

  tags = ["terraform", "multiaz"]
}

output "kapsule" {
  description = "Kapsule cluster id"
  value       = scaleway_k8s_cluster.kapsule.id
}

###
# Pool
###
resource "scaleway_k8s_pool" "pool" {
  for_each = {
    "fr-par-1" = "PLAY2-NANO",
    "fr-par-2" = "PLAY2-NANO",
    "fr-par-3" = "PRO2-XXS"
  }

  name       = each.key
  cluster_id = scaleway_k8s_cluster.kapsule.id
  zone       = each.key

  node_type = each.value

  size                   = 2
  min_size               = 2
  max_size               = 3
  autoscaling            = true
  autohealing            = true
  container_runtime      = "containerd"
  root_volume_size_in_gb = 32

  placement_group_id = scaleway_instance_placement_group.pg_kapsule[each.key].id

  tags = ["terraform", "multiaz"]
}

###
# Placement Group
###
resource "scaleway_instance_placement_group" "pg_kapsule" {
  name = "k8s-default-${var.zone}"
  zone = var.zone

  policy_mode = "enforced"
  policy_type = "max_availability"

  tags = ["terraform", "default"]
}

###
# Kapsule
###
resource "scaleway_k8s_cluster" "kapsule" {
  name = "default-${var.region}"

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

  tags = ["terraform", "default"]

  depends_on = [
    scaleway_vpc_private_network.pn
  ]
}

output "kapsule" {
  description = "Kapsule cluster id"
  value       = scaleway_k8s_cluster.kapsule.id
}

###
# Pool
###
resource "scaleway_k8s_pool" "pool" {
  name       = var.zone
  cluster_id = scaleway_k8s_cluster.kapsule.id
  zone       = var.zone

  node_type = "PLAY2-NANO"

  size                   = 2
  min_size               = 2
  max_size               = 3
  autoscaling            = true
  autohealing            = true
  container_runtime      = "containerd"
  root_volume_size_in_gb = 32

  placement_group_id = scaleway_instance_placement_group.pg_kapsule.id

  tags = ["terraform", "default"]

  depends_on = [
    scaleway_instance_placement_group.pg_kapsule,
    scaleway_k8s_cluster.kapsule
  ]
}

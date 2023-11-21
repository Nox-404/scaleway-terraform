resource "scaleway_lb_ip" "ingress_ip" {
    zone = var.zone
}

###
# Ingress Controller
###
resource "helm_release" "nginx_ingress" {
  name      = "ingress-nginx"
  namespace = "ingress"

  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  # One per node.
  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }

  # Use provisionned IP
  set {
    name  = "controller.service.loadBalancerIP"
    value = scaleway_lb_ip.ingress_ip.ip_address
  }

  # This is for the proxy protocol to be enabled on the LB side.
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/scw-loadbalancer-proxy-protocol-v2"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/scw-loadbalancer-use-hostname"
    value = "true"
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/scw-loadbalancer-zone"
    value = var.zone
    type  = "string"
  }

  # This is for the proxy protocol to be enabled on the controller side.
  set {
    name  = "controller.config.use-forwarded-headers"
    value = true
  }
  set {
    name  = "controller.config.compute-full-forwarded-for"
    value = true
  }
  set {
    name  = "controller.config.use-proxy-protocol"
    value = true
  }

  depends_on = [
    # Kapsule is not ready until a pool is.
    scaleway_k8s_pool.pool
  ]
}

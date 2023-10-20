###
# Ingress Controller
###
resource "helm_release" "nginx_ingress" {
  provider = helm.multiaz

  name      = "ingress-nginx"
  namespace = "ingress"

  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [
    <<-EOT
    controller:
      replicaCount: 6
      topologySpreadConstraints:
        - topologyKey: topology.kubernetes.io/zone
          maxSkew: 1
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: ingress-nginx
              app.kubernetes.io/instance: ingress-nginx
              app.kubernetes.io/component: controller
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                app.kubernetes.io/name: ingress-nginx
                app.kubernetes.io/instance: ingress-nginx
                app.kubernetes.io/component: controller
            topologyKey: "kubernetes.io/hostname"
      service:
        enabled: false
      config:
        location-snippet: |
          location /up {
            return 200 'up';
          }
        # Configure the ingress controller to use Proxy-Protocol
        use-forwarded-headers: "true"
        compute-full-forwarded-for: "true"
        use-proxy-protocol: "true"
    EOT
  ]

  depends_on = [
    scaleway_k8s_pool.pool
  ]
}

###
# Load Balancers
###
resource "scaleway_lb_ip" "ingress_ip" {
  for_each = toset(["fr-par-1", "fr-par-2"])
  zone = each.key
}

resource "kubernetes_service" "nginx" {
  provider = kubernetes.multiaz

  for_each = toset(["fr-par-1", "fr-par-2"])

  metadata {
    name      = "ingress-nginx-controller-${each.key}"
    namespace = helm_release.nginx_ingress.namespace

    annotations = {
      "service.beta.kubernetes.io/scw-loadbalancer-zone" : each.key
      "service.beta.kubernetes.io/scw-loadbalancer-proxy-protocol-v2" : "true"
      "service.beta.kubernetes.io/scw-loadbalancer-use-hostname" : "true"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name"      = "ingress-nginx"
      "app.kubernetes.io/instance"  = "ingress-nginx"
      "app.kubernetes.io/component" = "controller"
    }

    load_balancer_ip = scaleway_lb_ip.ingress_ip[each.key].ip_address

    port {
      app_protocol = "http"
      name         = "http"
      port         = 80
      protocol     = "TCP"
      target_port  = "http"
    }

    port {
      app_protocol = "https"
      name         = "https"
      port         = 443
      protocol     = "TCP"
      target_port  = "https"
    }

    type = "LoadBalancer"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["service.beta.kubernetes.io/scw-loadbalancer-id"],
      metadata[0].labels["k8s.scaleway.com/cluster"],
      metadata[0].labels["k8s.scaleway.com/kapsule"],
      metadata[0].labels["k8s.scaleway.com/managed-by-scaleway-cloud-controller-manager"],
    ]
  }

  depends_on = [
    helm_release.nginx_ingress,
    scaleway_k8s_pool.pool,
    scaleway_lb_ip.ingress_ip
  ]
}

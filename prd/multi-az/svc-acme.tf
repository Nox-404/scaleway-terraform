###
# Cert-Manager
###
resource "helm_release" "cert_manager" {
  provider = helm.multiaz

  name      = "cert-manager"
  namespace = "ingress"

  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  set {
    name = "installCRDs"
    value = true
  }

  depends_on = [
    scaleway_k8s_pool.pool
  ]
}

###
# Cert-Manager cluster issuer
###
resource "kubectl_manifest" "cert_manager_cluster_issuer" {
  provider = kubectl.multiaz

  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-prod
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: letsencrypt-prod
        solvers:
          - http01:
              ingress:
                ingressClassName: nginx
    YAML

  depends_on = [
    helm_release.cert_manager,
    scaleway_k8s_pool.pool
  ]
}

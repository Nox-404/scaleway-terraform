###
# Cert-Manager
###
resource "helm_release" "cert_manager" {
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
    # Kapsule is not ready until a pool is.
    scaleway_k8s_pool.pool
  ]
}

###
# Cert-Manager cluster issuer
###
resource "kubectl_manifest" "cert_manager_cluster_issuer" {
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
    # ClusterIssuer is not available until cert-manager is installed.
    helm_release.cert_manager,
    # Kapsule is not ready until a pool is.
    scaleway_k8s_pool.pool,
  ]
}

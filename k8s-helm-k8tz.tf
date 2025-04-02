resource "helm_release" "k8tz" {
  depends_on = [module.eks, module.vpc]

  name       = "k8tz"
  repository = "https://k8tz.github.io/k8tz/"
  chart      = "k8tz"
  version    = "0.18.0"
  wait       = true

  set {
    name  = "timezone"
    value = "UTC"
  }
}

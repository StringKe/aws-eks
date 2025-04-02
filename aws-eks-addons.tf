module "eks_blueprints_addons" {
  depends_on = [module.eks, kubernetes_storage_class_v1.ebs, kubernetes_storage_class_v1.ebs_auto_remove, module.ebs_csi_driver_irsa]
  source     = "aws-ia/eks-blueprints-addons/aws"
  version    = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = false

  enable_external_dns = false
  external_dns = {
    values = [templatefile("${path.module}/helm-values/external-dns.yaml", {
      txtOwnerId   = module.eks.cluster_name
      domainFilter = ["sg-123.com", "devsg.link"]
    })]
  }

  enable_cert_manager = true
  cert_manager = {
    wait = true
  }
  cert_manager_route53_hosted_zone_arns = ["arn:aws:route53:::hostedzone/*"]

  enable_ingress_nginx = false
  ingress_nginx = {
    atomic = false
    set = [
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
        value = "external"
        type  = "string"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
        value = "instance"
        type  = "string"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
        value = "internet-facing"
        type  = "string"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
        value = "true"
        type  = "string"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-idle-timeout"
        value = "3600"
        type  = "string"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-healthcheck-timeout"
        value = "10"
        type  = "string"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-healthcheck-interval"
        value = "30"
        type  = "string"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-healthcheck-healthy-threshold"
        value = "2"
        type  = "string"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-healthcheck-unhealthy-threshold"
        value = "2"
        type  = "string"
      }
    ]
  }

  enable_aws_cloudwatch_metrics = false
  enable_aws_for_fluentbit      = false
  aws_for_fluentbit_cw_log_group = {
    create            = true
    use_name_prefix   = false
    name              = "/${module.eks.cluster_name}/logs"
    retention_in_days = 90
  }
  aws_for_fluentbit = {
    name             = "aws-for-fluent-bit"
    namespace        = "fluentbit"
    create_namespace = true
    atomic           = true
    wait             = true
    values = [templatefile("${path.module}/helm-values/aws-for-fluentbit.yaml", {
      region               = var.region,
      cloudwatch_log_group = "/${module.eks.cluster_name}/logs"
      cluster_name         = module.eks.cluster_name
    })]
  }

  tags = var.tags
}

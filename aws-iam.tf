# 创建 EBS CSI 驱动程序所需的 IAM 角色
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${module.eks.cluster_name}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

# 创建 External DNS 所需的 IAM 角色
module "external_dns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name = "${module.eks.cluster_name}-external-dns"

  # 使用已创建的策略
  role_policy_arns = {
    ExternalDNSPolicy = aws_iam_policy.external_dns_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = var.tags
}

# 创建 External DNS 所需的 IAM 策略
resource "aws_iam_policy" "external_dns_policy" {
  name        = "${module.eks.cluster_name}-external-dns-policy"
  description = "Policy that allows External DNS to manage Route53 records"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = ["*"]
      }
    ]
  })

  tags = var.tags
}


# CloudWatch 可观测性所需的 IAM 角色
module "cloudwatch_observability_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name = "${module.eks.cluster_name}-cloudwatch-observability"

  attach_cloudwatch_observability_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:cloudwatch-agent"]
    }
  }

  tags = var.tags
}

# 网络流监控代理所需的 IAM 角色
module "network_flow_monitoring_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name = "${module.eks.cluster_name}-network-flow-monitoring"

  # 使用预定义策略或自定义策略
  role_policy_arns = {
    NetworkFlowPolicy = aws_iam_policy.network_flow_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["aws-network-flow-monitoring:network-flow-agent"]
    }
  }

  tags = var.tags
}

# 创建网络流监控所需的策略
resource "aws_iam_policy" "network_flow_policy" {
  name        = "${module.eks.cluster_name}-network-flow-policy"
  description = "IAM policy for AWS Network Flow Monitoring Agent"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

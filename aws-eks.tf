module "eks" {
  depends_on = [module.vpc]
  source     = "terraform-aws-modules/eks/aws"
  version    = "~> 20.0"

  cluster_name                             = local.cluster_name
  cluster_version                          = var.cluster_version
  cluster_ip_family                        = var.cluster_ip_family
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_private_access          = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    metrics-server = {
      most_recent = true
    }
    snapshot-controller = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    cert-manager = {
      most_recent = true
    }
    kube-state-metrics = {
      most_recent = true
    }
    eks-node-monitoring-agent = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    external-dns = {
      most_recent              = true
      service_account_role_arn = module.external_dns_irsa.iam_role_arn
    }
    aws-guardduty-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    aws-network-flow-monitoring-agent = {
      most_recent              = true
      service_account_role_arn = module.network_flow_monitoring_irsa.iam_role_arn
    }
    amazon-cloudwatch-observability = {
      most_recent              = true
      service_account_role_arn = module.cloudwatch_observability_irsa.iam_role_arn
    }
  }

  eks_managed_node_groups = {
    mini_general = {
      name           = "mini-general"
      desired_size   = 5
      min_size       = 5
      max_size       = 32
      instance_types = ["t3.medium", "t3a.medium"]
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_x86_64"

      labels = {
        workload_type = "general"
        size          = "mini"
      }
    },

    small_general = {
      name           = "small-general"
      desired_size   = 0
      min_size       = 0
      max_size       = 32
      instance_types = ["t3.large", "t3a.large"]
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_x86_64"

      labels = {
        workload_type = "general"
        size          = "small"
      }
    },

    medium_compute = {
      name           = "medium-compute"
      desired_size   = 0
      min_size       = 0
      max_size       = 32
      instance_types = ["c5.xlarge", "c5a.xlarge"]
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_x86_64"

      labels = {
        workload_type = "compute"
        size          = "medium"
      }
    },

    medium_memory = {
      name           = "medium-memory"
      desired_size   = 0
      min_size       = 0
      max_size       = 32
      instance_types = ["r5.large", "r5a.large"]
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_x86_64"

      labels = {
        workload_type = "memory"
        size          = "medium"
      }
    },

    large_memory = {
      name           = "large-memory"
      desired_size   = 0
      min_size       = 0
      max_size       = 32
      instance_types = ["r5.xlarge", "r5a.xlarge"]
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_x86_64"

      labels = {
        workload_type = "memory"
        size          = "large"
      }

      taints = {
        dedicated = {
          key    = "workload-type"
          value  = "memory-intensive"
          effect = "NO_SCHEDULE"
        }
      }
    },

    spot_general = {
      name           = "spot-general"
      desired_size   = 2
      min_size       = 0
      max_size       = 20
      instance_types = ["t3.large", "t3a.large", "m5.large", "m5a.large"]
      capacity_type  = "SPOT"
      ami_type       = "AL2_x86_64"

      labels = {
        workload_type = "general"
        size          = "small"
        pricing       = "spot"
      }
    }
  }

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  tags = var.tags
}

resource "aws_security_group" "guardduty" {
  name        = "guardduty_vpce_allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_vpc_endpoint" "guardduty" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.guardduty-data"
  subnet_ids          = module.vpc.private_subnets
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.guardduty.id]
  private_dns_enabled = true

  tags = var.tags
}

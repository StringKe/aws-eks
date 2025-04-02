output "cluster_name" {
  description = "集群名称"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "集群的端点"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "集群的安全组 ID"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "集群的 IAM 角色名称"
  value       = module.eks.cluster_iam_role_name
}

output "vpc_id" {
  description = "网络 VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "私有子网的 ID 列表"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "公共子网的 ID 列表"
  value       = module.vpc.public_subnets
}

output "oidc_provider_arn" {
  description = "OIDC 提供者的 ARN"
  value       = module.eks.oidc_provider_arn
}

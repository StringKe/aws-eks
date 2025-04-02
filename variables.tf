variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "EKS 集群的名称"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes 集群版本"
  type        = string
}

variable "cluster_ip_family" {
  description = "集群 IP 地址族（ipv4 或 ipv6）"
  type        = string
  default     = "ipv4"
}

variable "vpc_cidr" {
  description = "VPC 的 CIDR 块"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "应用到所有资源的标签"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
}

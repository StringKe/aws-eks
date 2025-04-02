resource "kubernetes_storage_class_v1" "ebs" {
  depends_on = [module.eks]

  metadata {
    name = "ebs"
    annotations = {
      "storageclass.beta.kubernetes.io/is-default-class"  = "true"
      "storageclass.kubernetes.io/is-default-class"       = "true"
      "storageclass.kubesphere.io/allow-clone"            = "true"
      "storageclass.kubesphere.io/allow-snapshot"         = "true"
      "storageclass.kubesphere.io/supported-access-modes" = "[\"ReadWriteOnce\",\"ReadOnlyMany\",\"ReadWriteMany\"]"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true

  parameters = {
    encrypted = "false"
    type      = "gp3"
    fsType    = "ext4"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["kubesphere.io/pvc-count"]
    ]
  }
}

resource "kubernetes_storage_class_v1" "ebs_auto_remove" {
  depends_on = [module.eks]

  metadata {
    name = "ebs-auto-remove"
    annotations = {
      "storageclass.kubesphere.io/allow-clone"            = "true"
      "storageclass.kubesphere.io/allow-snapshot"         = "true"
      "storageclass.kubesphere.io/supported-access-modes" = "[\"ReadWriteOnce\",\"ReadOnlyMany\",\"ReadWriteMany\"]"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true

  parameters = {
    encrypted = "false"
    type      = "gp3"
    fsType    = "ext4"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["kubesphere.io/pvc-count"]
    ]
  }
}

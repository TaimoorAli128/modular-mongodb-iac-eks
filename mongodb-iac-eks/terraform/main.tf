
module "eks" {
  source = "./modules/eks"

  name                       = var.name
  region                     = var.region
  vpc_cidr                   = var.vpc_cidr
  mongodb_node_instance_type = var.mongodb_node_instance_type
  mongodb_node_desired_size  = var.mongodb_node_desired_size
}

module "storage" {
  source = "./modules/storage"

  name   = var.name
  region = var.region
}

module "platform" {
  source = "./modules/platform"

  name                      = var.name
  cluster_name              = module.eks.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_oidc_provider_url = module.eks.oidc_provider_url

  s3_backup_bucket_arn  = module.storage.s3_bucket_arn
  s3_backup_bucket_name = module.storage.s3_bucket_name
  s3_kms_key_arn        = module.storage.s3_kms_key_arn

  percona_operator_version     = var.percona_operator_version
  cert_manager_version         = var.cert_manager_version
  enable_monitoring            = var.enable_monitoring
  kube_prometheus_stack_version = var.kube_prometheus_stack_version
}

resource "kubernetes_namespace" "app" {
  metadata { name = "app" }
}

resource "kubernetes_namespace" "database" {
  metadata { name = "database" }
}

resource "kubernetes_namespace" "monitoring" {
  metadata { name = "monitoring" }
}

resource "kubernetes_storage_class_v1" "gp3_encrypted" {
  metadata { name = "gp3-encrypted" }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
}

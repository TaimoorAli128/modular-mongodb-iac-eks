
output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = var.region
}

output "s3_backup_bucket" {
  value = module.storage.s3_bucket_name
}

output "pbm_irsa_role_arn" {
  value = module.platform.pbm_irsa_role_arn
}

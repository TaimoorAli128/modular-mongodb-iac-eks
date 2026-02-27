
variable "name" { type = string }

variable "cluster_name" { type = string }
variable "cluster_oidc_provider_arn" { type = string }
variable "cluster_oidc_provider_url" { type = string }

variable "s3_backup_bucket_arn" { type = string }
variable "s3_backup_bucket_name" { type = string }
variable "s3_kms_key_arn" { type = string }

variable "percona_operator_version" { type = string }
variable "cert_manager_version" { type = string }
variable "enable_monitoring" { type = bool }
variable "kube_prometheus_stack_version" { type = string }

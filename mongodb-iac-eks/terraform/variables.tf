
variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Base name/prefix for resources."
  type        = string
  default     = "mongodb-iac"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "mongodb_node_instance_type" {
  description = "Instance type for dedicated MongoDB node group."
  type        = string
  default     = "t3.large"
}

variable "mongodb_node_desired_size" {
  description = "Desired size for MongoDB node group."
  type        = number
  default     = 3
}

variable "enable_monitoring" {
  description = "Install kube-prometheus-stack (Prometheus/Grafana/Alertmanager)."
  type        = bool
  default     = true
}

variable "percona_operator_version" {
  description = "Helm chart version for Percona MongoDB Operator."
  type        = string
  default     = "1.17.0"
}

variable "cert_manager_version" {
  description = "Helm chart version for cert-manager."
  type        = string
  default     = "v1.15.3"
}

variable "kube_prometheus_stack_version" {
  description = "Helm chart version for kube-prometheus-stack."
  type        = string
  default     = "61.6.0"
}

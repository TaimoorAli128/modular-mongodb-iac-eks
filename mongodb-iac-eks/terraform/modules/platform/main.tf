
locals {
  pbm_namespace = "database"
  pbm_sa_name   = "pbm-s3"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.cluster_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.pbm_namespace}:${local.pbm_sa_name}"]
    }
  }
}

resource "aws_iam_role" "pbm" {
  name               = "${var.name}-pbm-irsa"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "pbm_access" {
  statement {
    sid     = "S3List"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [var.s3_backup_bucket_arn]
  }

  statement {
    sid     = "S3Objects"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.s3_backup_bucket_arn}/*"]
  }

  statement {
    sid     = "KMS"
    effect  = "Allow"
    actions = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey"]
    resources = [var.s3_kms_key_arn]
  }
}

resource "aws_iam_policy" "pbm_access" {
  name   = "${var.name}-pbm-s3-policy"
  policy = data.aws_iam_policy_document.pbm_access.json
}

resource "aws_iam_role_policy_attachment" "pbm_attach" {
  role       = aws_iam_role.pbm.name
  policy_arn = aws_iam_policy.pbm_access.arn
}

resource "kubernetes_service_account" "pbm" {
  metadata {
    name      = local.pbm_sa_name
    namespace = local.pbm_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.pbm.arn
    }
  }
  automount_service_account_token = true
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_version
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "percona_mongodb_operator" {
  name       = "percona-mongodb-operator"
  namespace  = "database"
  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-operator"
  version    = var.percona_operator_version
  create_namespace = true
  depends_on = [helm_release.cert_manager]
}

resource "helm_release" "kube_prometheus_stack" {
  count      = var.enable_monitoring ? 1 : 0
  name       = "kube-prometheus-stack"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.kube_prometheus_stack_version
  create_namespace = true
}

output "pbm_irsa_role_arn" {
  value = aws_iam_role.pbm.arn
}


locals {
  bucket_name = "${var.name}-pbm-backups-${var.region}"
  tags = { Project = var.name }
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 PBM backups (${var.name})"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.name}-s3-backups"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_s3_bucket" "pbm" {
  bucket = local.bucket_name
  tags   = local.tags
}

resource "aws_s3_bucket_versioning" "pbm" {
  bucket = aws_s3_bucket.pbm.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pbm" {
  bucket = aws_s3_bucket.pbm.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pbm" {
  bucket                  = aws_s3_bucket.pbm.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "pbm" {
  bucket = aws_s3_bucket.pbm.id
  rule {
    id     = "lifecycle"
    status = "Enabled"
    transition {
      days          = 14
      storage_class = "STANDARD_IA"
    }
    expiration { days = 180 }
  }
}

output "s3_bucket_name" { value = aws_s3_bucket.pbm.bucket }
output "s3_bucket_arn"  { value = aws_s3_bucket.pbm.arn }
output "s3_kms_key_arn" { value = aws_kms_key.s3.arn }

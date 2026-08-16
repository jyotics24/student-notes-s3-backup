terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "mysql_backup" {
  bucket = var.bucket_name

  tags = {
    Name        = "student-notes-mysql-backup"
    Environment = "lab"
    Purpose     = "MySQL backup storage"
  }
}

resource "aws_s3_bucket_public_access_block" "mysql_backup" {
  bucket = aws_s3_bucket.mysql_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mysql_backup" {
  bucket = aws_s3_bucket.mysql_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
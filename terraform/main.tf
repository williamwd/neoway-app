provider "aws" {
  region = "us-east-1"
}

data "aws_kms_alias" "s3kmskey" {
  name = "alias/kmsKey"
}


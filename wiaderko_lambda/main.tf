terraform {
  backend "s3" {
    bucket         = "terraform-kurs-wiaderko-199548"
    key            = "serverless/kod_lambda/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terrform_tabela_stan"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "serverless-lambda-code-wiaderko-19945221"  # lub możesz wygenerować dynamicznie np. z var albo timestamp
}

resource "aws_secretsmanager_secret" "bucket_name_secret" {
  name = "my-bucket-name-secret-v2"
}

resource "aws_secretsmanager_secret_version" "bucket_name_secret_version" {
  secret_id     = aws_secretsmanager_secret.bucket_name_secret.id
  secret_string = jsonencode({
    bucket_name = aws_s3_bucket.my_bucket.bucket
  })
}

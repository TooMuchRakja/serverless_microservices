output "lambda_code_bucket_name" {
    description = "Wiaderko do przechowywania kodu z workflow"
    value = aws_s3_bucket.my_bucket.bucket
}
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "userfunctions_lambda_role" {
  name = "${var.role_name}-lambda_role"
  description = "Lambda function IAM role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "userfunctions_lambda_role_policy" {
  name        = "${var.role_name}-role_policy"
  description = "Lambda function policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:PutItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:BatchGetItem",
        "dynamodb:DescribeTable",
        "dynamodb:ConditionCheckItem"
      ],
      "Effect": "Allow",
      "Resource": "arn:*:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"
    },
    {
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "xray:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "userfunctions_lambda_attach" {
  name       = "${var.function_name}-lambda_attachment"
  roles      = [aws_iam_role.userfunctions_lambda_role.name]
  policy_arn = aws_iam_policy.userfunctions_lambda_role_policy.arn
}
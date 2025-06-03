
output "sns_topic_arn" {
    value = aws_sns_topic.alarms_topic.arn
}

output "sns_email" {
    value = var.sns_email
}
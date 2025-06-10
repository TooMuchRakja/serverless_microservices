resource "aws_sns_topic" "alarms_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "alarms_subscription" {
  topic_arn = aws_sns_topic.alarms_topic.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

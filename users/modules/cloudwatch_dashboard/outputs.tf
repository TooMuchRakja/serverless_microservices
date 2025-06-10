output "dashboard_url" {
    value = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.application_dashboard.dashboard_name}"
}
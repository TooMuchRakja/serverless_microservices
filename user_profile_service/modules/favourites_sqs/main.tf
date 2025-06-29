resource "aws_sqs_queue" "favourites_sqs" {
    name = "favourites_sqs_queue"
    message_retention_seconds = 86400 # 1 day

    tags {
        Environment = "${var.environment}"
        stack_name =  "${var.stack_name}"
    }
}

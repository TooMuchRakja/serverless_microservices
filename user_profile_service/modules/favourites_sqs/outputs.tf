output "favourites_sqs_queue_arn" {
    value = aws_sqs_queue.favourites_sqs.arn
}

output "favourites_sqs_queue_name" {
    value = aws_sqs_queue.favourites_sqs.name
}

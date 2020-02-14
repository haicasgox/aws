output "sns_arn" {
  value = "${aws_sns_topic.HAINT_notification.arn}"
}

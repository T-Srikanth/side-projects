resource "aws_sns_topic" "openops_notifications" {
  name = "openops-deploy-status"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.openops_notifications.arn
  protocol  = "email"
  endpoint  = var.sns_sbuscrition_email
}
resource "aws_iam_role" "openops_instance_role" {
  name = "openops-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "sns_publish_policy" {
  name        = "sns-publish-policy"
  description = "Allows EC2 to publish to the OpenOps SNS topic"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = aws_sns_topic.openops_notifications.arn
      }
    ]
  })
}

resource "aws_iam_policy" "secretsmanager_put_policy" {
  name = "secretsmanager-put-secret-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "openops_secretsmanager_policy_attach" {
  role       = aws_iam_role.openops_instance_role.name
  policy_arn = aws_iam_policy.secretsmanager_put_policy.arn
}

resource "aws_iam_role_policy_attachment" "openops_sns_policy_attach" {
  role       = aws_iam_role.openops_instance_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

resource "aws_iam_instance_profile" "openops_instance_profile" {
  name = "openops-ec2-instance-profile"
  role = aws_iam_role.openops_instance_role.name
}

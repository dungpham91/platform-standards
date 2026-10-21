resource "aws_sns_topic" "platform_alerts" {
  name              = "${var.name_prefix}-${var.environment}-platform-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

data "archive_file" "slack_lambda" {
  count       = var.enable_slack_notifications ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/lambda/slack_notify.py"
  output_path = "${path.module}/lambda/slack_notify.zip"
}

resource "aws_iam_role" "slack_lambda" {
  count = var.enable_slack_notifications ? 1 : 0
  name  = "${var.name_prefix}-${var.environment}-slack-notify"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "slack_lambda_basic" {
  count      = var.enable_slack_notifications ? 1 : 0
  role       = aws_iam_role.slack_lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "slack_notify" {
  count         = var.enable_slack_notifications ? 1 : 0
  function_name = "${var.name_prefix}-${var.environment}-slack-notify"
  role          = aws_iam_role.slack_lambda[0].arn
  handler       = "slack_notify.handler"
  runtime       = "python3.12"
  filename      = data.archive_file.slack_lambda[0].output_path
  source_code_hash = data.archive_file.slack_lambda[0].output_base64sha256

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

resource "aws_lambda_permission" "sns_invoke" {
  count         = var.enable_slack_notifications ? 1 : 0
  statement_id  = "AllowSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notify[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.platform_alerts.arn
}

resource "aws_sns_topic_subscription" "slack" {
  count     = var.enable_slack_notifications ? 1 : 0
  topic_arn = aws_sns_topic.platform_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notify[0].arn
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.alb_arn_suffix != "" ? 1 : 0

  alarm_name          = "${var.name_prefix}-${var.environment}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_description  = "Trading edge ALB target 5xx spike"
  alarm_actions      = [aws_sns_topic.platform_alerts.arn]
  ok_actions         = [aws_sns_topic.platform_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.name_prefix}-${var.environment}-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = "${var.name_prefix}-${var.environment}-orders"
  }

  alarm_description = "Orders RDS CPU high"
  alarm_actions     = [aws_sns_topic.platform_alerts.arn]
  ok_actions        = [aws_sns_topic.platform_alerts.arn]
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}

resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_name
  role         = aws_iam_role.lambda_exec.arn
  handler      = "lambda_function.lambda_handler"
  runtime      = "python3.9"
  filename     = "lambda_function.zip"
  source_code_hash = ("lambda_function.zip")

  environment {
    variables = {
      bucket_name = aws_s3_bucket.my_bucket.id
    }
  }

  depends_on = [
    aws_s3_bucket.my_bucket,
    aws_iam_role.lambda_exec
  ]
}

resource "aws_iam_role" "lambda_exec" {
  name = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = "prod"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role = aws_iam_role.lambda_exec.name
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name        = "s3-bucket-cleanup"
  description = "A rule to schedule the Lambda function"
  schedule_expression = "cron(0 0 * * SUN)"
}

resource "aws_cloudwatch_event_rule" "trigger_detect_lingering_files" {
  name                = "trigger_detect_lingering_files"
  description         = "Trigger the detect_lingering_files Lambda function every Sunday at midnight"
  schedule_expression = "cron(0 0 * * SUN *)"
}

resource "aws_cloudwatch_event_target" "detect_lingering_files" {
  rule = aws_cloudwatch_event_rule.trigger_detect_lingering_files.name
  arn  = aws_lambda_function.detect_lingering_files.arn
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  arn       = aws_lambda_function.my_lambda.arn
  input     = jsonencode({
    bucket_name = aws_s3_bucket.my_bucket.id
  })
}

data "aws_iam_policy_document

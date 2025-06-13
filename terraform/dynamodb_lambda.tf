resource "aws_dynamodb_table" "domains" {
  name         = "domains"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "domain"

  attribute {
    name = "domain"
    type = "S"
  }
}

resource "aws_lambda_function" "api" {
  function_name = "domain_api"
  filename      = "lambda.zip"   # Path to your zipped Lambda code
  handler       = "handler.lambda_handler"
  runtime       = "python3.10"
  role          = "🔴"  # IAM role ARN for Lambda exec, e.g. aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.domains.name
    }
  }

  source_code_hash = filebase64sha256("lambda.zip")
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.api.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "lambda-domain-api-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when Lambda errors exceed 0"
  dimensions = {
    FunctionName = aws_lambda_function.api.function_name
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "🔴"  # e.g. "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}


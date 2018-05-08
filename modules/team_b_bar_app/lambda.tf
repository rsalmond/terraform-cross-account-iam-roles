data "archive_file" "bar" {
  type        = "zip"
  source_file = "${path.module}/bar.py"
  output_path = "${path.module}/bar.zip"
}

resource "aws_lambda_function" "bar" {
  filename         = "${path.module}/bar.zip"
  function_name    = "bar"
  role             = "${aws_iam_role.bar.arn}"
  handler          = "bar.handler"
  source_code_hash = "${data.archive_file.bar.output_base64sha256}"
  runtime          = "python3.6"

  environment {
    variables = {
      FOO_ROLE = "${var.role_to_assume}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "bar" {
  name                = "bar"
  description         = "bar execution schedule"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "bar" {
  target_id = "bar"
  rule      = "${aws_cloudwatch_event_rule.bar.name}"
  arn       = "${aws_lambda_function.bar.arn}"
}

resource "aws_lambda_permission" "bar" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.bar.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.bar.arn}"
}

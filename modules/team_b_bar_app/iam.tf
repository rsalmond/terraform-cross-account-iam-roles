// Policy for Bar app Lambda function
data "aws_iam_policy_document" "bar" {
  // allow Bar app to write logs to cloudwatch (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/iam-identity-based-access-control-cwl.html)
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  // allow Bar app to operate in a VPC (https://docs.aws.amazon.com/lambda/latest/dg/vpc.html)
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
    ]

    resources = [
      "*",
    ]
  }

  // allow Bar app to assume the Foo app role provided to us for accessing their DDB table.
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${var.role_to_assume}",
    ]
  }
}

/* 
Another assumerole happening here but in this case we allow the AWS Lambda service
to assume the role we create in this file, which will subsequently be used by Bar app to 
then assume the role in Account A
*/

data "aws_iam_policy_document" "bar_assumerole" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "bar" {
  name        = "bar"
  path        = "/"
  description = "Policy for Bar app Lambda function"
  policy      = "${data.aws_iam_policy_document.bar.json}"
}

resource "aws_iam_role" "bar" {
  name               = "bar"
  assume_role_policy = "${data.aws_iam_policy_document.bar_assumerole.json}"
}

resource "aws_iam_role_policy_attachment" "bar" {
  role       = "${aws_iam_role.bar.name}"
  policy_arn = "${aws_iam_policy.bar.arn}"
}

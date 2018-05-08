//This is the actual policy you want to grant the other account access to use.
data "aws_iam_policy_document" "foo" {
  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      "${aws_dynamodb_table.foo.arn}",
    ]
  }
}

// This will define the trust policy for the role.
data "aws_iam_policy_document" "foo-assume-role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${var.team_b_role}"]
    }
  }
}

// Here we create the policy, create the role, and attach them together.
resource "aws_iam_policy" "foo" {
  name        = "foo_bar"
  path        = "/"
  description = "Policy for team B Bar app to access Foo app ddb tables."
  policy      = "${data.aws_iam_policy_document.foo.json}"
}

resource "aws_iam_role" "foo" {
  assume_role_policy = "${data.aws_iam_policy_document.foo-assume-role.json}"
  name               = "foo_bar"
  path               = "/"
}

resource "aws_iam_role_policy_attachment" "foo" {
  role       = "${aws_iam_role.foo.name}"
  policy_arn = "${aws_iam_policy.foo.arn}"
}

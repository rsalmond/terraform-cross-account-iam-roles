resource "aws_dynamodb_table" "foo" {
  name           = "${var.table_name}"
  read_capacity  = "${var.read_capacity}"
  write_capacity = "${var.write_capacity}"
  hash_key       = "MyPrimaryKey"

  attribute {
    name = "MyPrimaryKey"
    type = "S"
  }
}

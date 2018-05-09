module "ddb_module" "foo_ddb" {
  source         = "../../modules/team_a_foo_ddb"
  table_name     = "TestTable"
  read_capacity  = "5"
  write_capacity = "5"
  role_which_will_assume = "arn:aws:iam::222222222222:root"
}

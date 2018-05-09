module "ddb_module" "foo_ddb" {
  source         = "../../modules/team_a_foo_ddb"
  table_name     = "TestTable"
  read_capacity  = "5"
  write_capacity = "5"
  //TODO: use dummy acct no
  team_b_role    = "arn:aws:iam::703091623098:root"
}

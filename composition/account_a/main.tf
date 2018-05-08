module "ddb_module" "foo_ddb" {
  source         = "../../modules/team_a_foo_ddb"
  table_name     = "TestTable"
  read_capacity  = "5"
  write_capacity = "5"
  team_b_role    = ""
}

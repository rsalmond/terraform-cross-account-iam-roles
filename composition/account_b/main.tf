module "lambda_module" "bar_iam" {
  source = "../../modules/team_b_bar_app"
  //role_to_assume = "*"
  //TODO: use the above
  role_to_assume = "arn:aws:iam::703091623098:role/foo_bar"
}

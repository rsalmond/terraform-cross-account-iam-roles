module "lambda_module" "bar_iam" {
  source = "../../modules/team_b_bar_app"
  role_to_assume = "*"
}

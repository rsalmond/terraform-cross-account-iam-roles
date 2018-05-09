output "role_which_will_assume" {
  value = "${module.lambda_module.role_arn}"
}

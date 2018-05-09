output "role_to_be_assumed" {
  value = "${module.ddb_module.role_arn}"
}

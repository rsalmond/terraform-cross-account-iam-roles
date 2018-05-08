variable "table_name" {
  description = "Name of DDB table being created."
}

variable "read_capacity" {
  description = "DDB read capacity to provision."
}

variable "write_capacity" {
  description = "DDB write capacity to provision."
}

variable "team_b_role" {
  description = "The ARN of the role provided by Team B which will be granted access to assume our IAM role."
}

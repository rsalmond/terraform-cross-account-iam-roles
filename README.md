# Cross Account IAM Roles

### Why?

Because I can never remember it when I need it.

### What?

[Detailed explanation](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html).

tl;dr you have two AWS accounts. In account A you have some resource and you want to access that resource from some process
running in account B. eg. you have a DDB table in A and a cronjob on an ec2 instance in B is going to back it up every night. 

To do this you create two IAM roles, one in each account.

The one in account A grants access to DDB and has a [_trust policy_](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_terms-and-concepts.html) (see the delegation section) allowing the role in account B to assume the role in account A.

The one in account B only needs access to perform the [`sts:AssumeRole`](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) action.

You can basically think of a trust policy as "indicator of an external thing that is allowed to use this thing".

For this specific example the role in account A will grant access to write items into a DynamoDB table and the role in account B will be used by a Lambda function to assume the account A role and write data to Dynamo.

### How?

[Terraform](https://www.terraform.io/) of course! And a few other odds and ends. These examples assume you are making use of an [aws credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html) and that you have a [named profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html) for both accounts.

Eg.

```
cat ~/.aws/credentials

[account_a] # account id: 111111111111
aws_access_key_id = AKIA<...............>
aws_secret_access_key = entropyentropyentropyentropyentropyentro
region=us-east-1

[account_b] # account id: 222222222222
aws_access_key_id = AKIA<...............>
aws_secret_access_key = entropyentropyentropyentropyentropyentro
region=us-east-1
```

### Running

There are a few more steps required than you might initially think due to a little chicken-and-egg problem. We need to create an IAM role in account A which has a [trust policy](https://github.com/rsalmond/terraform-cross-account-iam-roles/blob/master/modules/team_a_foo_ddb/iam.tf#L16-L27) that refers to another IAM role in account B that doesn't exist yet. And we want to [limit](https://github.com/rsalmond/terraform-cross-account-iam-roles/blob/master/modules/team_b_bar_app/iam.tf#L29-L39) the role in account B to only be able to assume the role provided by account A, which also doesn't exist yet.

To get around this we will start by applying our account A terraform with a slightly less restrictive trust policy.

```
$ cat composition/account_a/main.tf
module "ddb_module" "foo_ddb" {
  source         = "../../modules/team_a_foo_ddb"
  table_name     = "TestTable"
  read_capacity  = "5"
  write_capacity = "5"
  role_which_will_assume = "arn:aws:iam::222222222222:root"
}
```

This will cause the role created in A to trust the entirety of account B (Note: swap in your account number), not just a specific role. Apply this terraform and note the ARN included in the output, we will add this to the account B composition next.

```
$ cd composition/account_a/ && terraform init && terraform apply

< ... snip ... >

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

role_to_be_assumed = arn:aws:iam::111111111111:role/foo_bar
```

Edit `composition/account_b/main.tf` and change the line `role_to_assume = "*"` replacing the `*` with the ARN outputted by the first apply, then apply the `account_b` composition.


```
$ cd composition/account_a/ && terraform init && terraform apply

< ... snip ... >

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

role_which_will_assume = arn:aws:iam::222222222222:role/bar
```

At this point you should be able to browse the [Lambda logs for the function called "bar"](https://console.aws.amazon.com/cloudwatch/home?logStream:group=/aws/lambda/bar;streamFilter=typeLogStreamPrefix) in account B and see successful completions. You should also be able to look at the [items in the TestTable](https://console.aws.amazon.com/dynamodb/home?tables:selected=TestTable) and see new records being written once a minute.

We can now go back to account A and tighten up that trust policy on that role by further restricting it from trusting all of account B to trusting only the role which will assume it. After editing it should look like this.

```
$ cat composition/account_a/main.tf
module "ddb_module" "foo_ddb" {
  source         = "../../modules/team_a_foo_ddb"
  table_name     = "TestTable"
  read_capacity  = "5"
  write_capacity = "5"
  role_which_will_assume = "arn:aws:iam::222222222222:role/bar"
}
```

Re-apply this to finish the job and double check that both the lambda is still completing successfully and the Dynamo table is still being written to. When you're done playing around don't forget to `terraform destroy` both compositions.

### Further Reading

If you are creating a role which will assume multiple roles in multiple AWS accounts you should read about [external IDs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html).

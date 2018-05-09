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

There are a few more steps required than you might initially think to get this cross account relationship set up, due to a little chicken-and-egg problem. We need to create an IAM role in account A which has a [trust policy] that refers to another IAM role in account B that doesn't exist yet. And we want to [limit] the role in account B to only be able to assume the role provided by account A, which also doesn't exist yet.


### Further Reading

If you are creating a role which will assume multiple roles in multiple AWS accounts you should read about [external IDs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html).

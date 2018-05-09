import os
import time
import boto3

def get_ddb_client():
    """
    Return a boto3 ddb client object using the remote account assumed role.
    see: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-api.html
    """
    # fetch the ARN of the role to assume from environment variable
    role_to_assume = os.environ.get('FOO_ROLE')

    sts_client = boto3.client('sts')

    assumed_role_object = sts_client.assume_role(
        RoleArn=role_to_assume,
        RoleSessionName='BarAppSession'
    )

    credentials = assumed_role_object.get('Credentials')

    if not credentials:
        # I have no idea if this would log anything sensitive, never seen it
        # happen.
        raise Exception('Error fetching creds: {}'.format(assumed_role_object))

    return boto3.client(
	'dynamodb',
	aws_access_key_id = credentials.get('AccessKeyId'),
	aws_secret_access_key = credentials.get('SecretAccessKey'),
	aws_session_token = credentials.get('SessionToken'),
    )


def handler(event, context):
    """
    called by AWS when lambda is invoked
    """

    ddb_client = get_ddb_client()

    # write a simple record to DDB, the current epoch time
    ddb_client.put_item(TableName='TestTable',
            Item={
                'MyPrimaryKey': {'S': str(int(time.time()))}
            }
        )

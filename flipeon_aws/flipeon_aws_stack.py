from aws_cdk import (
    Stack,
    aws_lambda as _lambda
)
from constructs import Construct

class FlipeonAwsStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # f = _lambda.Function(
        #     scope = self, 
        #     id = "CredentialsTest",
        #     runtime = _lambda.Runtime.PYTHON_3_10,
        #     handler="lambda_handler.handler",
        #     code= _lambda.Code.from_asset("flipeon_aws/permission_test")
        # )

        #  https://www.youtube.com/watch?v=0lNS4JZxrqc&t=3509s
        #  https://www.youtube.com/watch?v=8Clme-yicjU
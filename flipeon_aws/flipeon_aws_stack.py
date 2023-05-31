from aws_cdk import (
    Stack,
    aws_lambda as _lambda,
    aws_sqs as sqs,
    aws_lambda_event_sources as lambda_event_source,
    aws_s3 as s3,
    aws_iam as iam
)
from constructs import Construct

class FlipeonAwsStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)
        # NFCE
        # criando o bucket para armazenamento
        nfce_bucket = s3.Bucket(scope=self, id="bucket_nfce", bucket_name="nfce")

        # criando fila para processamento do lambda
        nfce_s3_queue = sqs.Queue(scope=self, id="NFCE_S3_QUEUE")

        # criando a lambda para armazenamento da NFCE
        nfce_s3_lambda = _lambda.Function(scope=self, id="NFCE_S3_LAMBDA_SQS_TRIGGER",
            handler='lambda_handler.handler',
            runtime=_lambda.Runtime.PYTHON_3_7,
            code=_lambda.Code.from_asset("flipeon_aws/nfce_s3_lambda")
        )
        nfce_s3_lambda.add_to_role_policy(statement=iam.PolicyStatement(
            effect = iam.Effect.ALLOW,
            actions = ["s3:PutObject", "s3:ListBucket", "s3:PutObjectAcl"],
            resources=[nfce_bucket.bucket_arn, f"{nfce_bucket.bucket_arn}/*"]
        ))

        # criando o evento do SQS para a lambda e associando ao sqs
        sqs_event_source = lambda_event_source.SqsEventSource(nfce_s3_queue)
        nfce_s3_lambda.add_event_source(sqs_event_source)
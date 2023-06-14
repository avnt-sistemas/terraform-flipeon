from aws_cdk import (
    Stack,
    aws_lambda as _lambda,
    aws_sqs as sqs,
    aws_lambda_event_sources as lambda_event_source,
    aws_s3 as s3,
    aws_iam as iam,
    Duration
)

from constructs import Construct

class FlipeonNFCeStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)
        # BUCKETS de NFCE
        # criando o buckets para armazenamento das nfces
        nfce_bucket = s3.Bucket(self, "nfce-xmls", bucket_name="nfce-xmls")
        # LAMBDA DE PROCESSAMENTO
        # criando fila para processamento do lambda
        nfce_s3_queue = sqs.Queue(self, "nfce-s3-queue", queue_name="nfce-s3-storage-queue")

        # criando a lambda para armazenamento da NFCE
        nfce_s3_lambda = _lambda.Function(self, "nfce-s3-lambda-storage",
            function_name="nfce-s3-lambda-storage",
            retry_attempts=1,
            memory_size=1024,
            handler='lambda_handler.handler',
            runtime=_lambda.Runtime.PYTHON_3_7,
            code=_lambda.Code.from_asset("flipeon_aws/nfce_s3_lambda"),
            environment={
                "FLIPEON_API": "http://localhost:51015",
                "DEST_S3_BUCKET": "nfce-xmls"
            }
        )

        nfce_s3_lambda.add_to_role_policy(statement=iam.PolicyStatement(
            effect=iam.Effect.ALLOW,
            actions=[
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:DeleteObject"
            ],
            resources=[
                nfce_bucket.bucket_arn, 
                f"{nfce_bucket.bucket_arn}/*"
            ]
        ))

        # criando o evento do SQS para a lambda e associando ao sqs
        sqs_event_source = lambda_event_source.SqsEventSource(nfce_s3_queue, batch_size=10)
        nfce_s3_lambda.add_event_source(sqs_event_source)

        # DoWNLOAD
        download_nfce_bucket = s3.Bucket(self, "nfce-download-temporario", bucket_name="nfce-download-temporario")
        download_nfce_bucket.add_lifecycle_rule(expiration=Duration.days(30))

        # criando a lambda para download da NFCE
        nfce_download_lambda = _lambda.Function(self, "nfce-download-lambda",
            function_name="nfce-download-lambda",
            retry_attempts=1,
            memory_size=1024,
            handler='lambda_handler.handler',
            runtime=_lambda.Runtime.PYTHON_3_7,
            code=_lambda.Code.from_asset("flipeon_aws/nfce_download_lambda")
        )


        nfce_download_lambda.add_to_role_policy(statement=iam.PolicyStatement(
            effect=iam.Effect.ALLOW,
            actions=[
                "s3:GetObject",
                "s3:GetObjectAcl"
            ],
            resources=[
                nfce_bucket.bucket_arn, 
                f"{nfce_bucket.bucket_arn}/*"
            ]
        ))

        nfce_download_lambda.add_to_role_policy(statement=iam.PolicyStatement(
            effect=iam.Effect.ALLOW,
            actions=[
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:DeleteObject"
            ],
            resources=[
                download_nfce_bucket.bucket_arn, 
                f"{download_nfce_bucket.bucket_arn}/*"
            ]
        ))
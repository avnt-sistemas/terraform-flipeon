#!/usr/bin/env python3
import aws_cdk as cdk

from flipeon_aws.flipeon_aws_stack import FlipeonAwsStack


app = cdk.App()
FlipeonAwsStack(app, "FlipeonAwsStack")
app.synth()

# env = cdk.Environment(account='457504760127', region='sa-east-1'),

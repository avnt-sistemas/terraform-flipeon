#!/usr/bin/env python3
import aws_cdk as cdk

from flipeon_aws.flipeon_nfce_stack import FlipeonNFCeStack


app = cdk.App()
FlipeonNFCeStack(app, "FlipeonNFCeStack")
app.synth()

# env = cdk.Environment(account='457504760127', region='sa-east-1'),

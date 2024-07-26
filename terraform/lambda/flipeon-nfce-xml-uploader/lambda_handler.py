import json
import boto3
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')
sqs_client = boto3.client('sqs')
lambda_client = boto3.client('lambda')

def lambda_handler(event, context):
    for record in event['Records']:
        payload = json.loads(record['body'])
        file_path = payload.get('caminho')
        file_name = payload.get('nome_arquivo')
        xml = payload.get('xml')
        # action = payload.get('acao')
        # nfce_id = payload.get('nfce_id')
        
        # Adicionar arquivo ao S3
        bucket_name = 'docs-bucket-flipeon-dev'
        s3_key = f"/nfce/{caminho}/{file_name}.xml"
        try:
            s3_client.put_object(Bucket=bucket_name, Key=s3_key, Body=xml)
            print(f"Uploaded {s3_key} to {bucket_name}")
        except ClientError as e:
            print(f"Error uploading to S3: {e}")
            return {
                'statusCode': 500,
                'body': json.dumps('Error uploading to S3')
            }

        # Chamar outra Lambda para adicionar o arquivo ao zip
        lambda_payload = {
            'bucket_name': bucket_name,
            's3_key': s3_key
        }
        try:
            response = lambda_client.invoke(
                FunctionName='flipeon-nfce-compactor',
                InvocationType='Event',
                Payload=json.dumps(lambda_payload)
            )
            print(f"Invoked zip lambda with response: {response}")
        except ClientError as e:
            print(f"Error invoking zip lambda: {e}")
            return {
                'statusCode': 500,
                'body': json.dumps('Error invoking zip lambda')
            }

    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }

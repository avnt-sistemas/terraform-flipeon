import json
import boto3
import zipfile
import io
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    bucket_name = event.get('bucket_name')
    s3_key = event.get('s3_key')

    splited = s3_key.split('/')
    xml_name = splited[-1]

    splited = splited[:-2] 

    zip_path = '/'.splited[0].'/'.splited[1]
    zip_name = f"{zip_path}/{splited[2]}.zip"

    
    # Baixar o arquivo XML
    try:
        xml_obj = s3_client.get_object(Bucket=bucket_name, Key=s3_key)
        xml_content = xml_obj['Body'].read()
    except ClientError as e:
        print(f"Error downloading XML from S3: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error downloading XML from S3')
        }

    # Baixar ou criar o arquivo zip
    try:
        zip_obj = s3_client.get_object(Bucket=bucket_name, Key=zip_name)
        zip_content = zip_obj['Body'].read()
        zip_buffer = io.BytesIO(zip_content)
        zip_file = zipfile.ZipFile(zip_buffer, 'a')
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchKey':
            zip_buffer = io.BytesIO()
            zip_file = zipfile.ZipFile(zip_buffer, 'w')
        else:
            print(f"Error downloading zip from S3: {e}")
            return {
                'statusCode': 500,
                'body': json.dumps('Error downloading zip from S3')
            }

    # Adicionar o arquivo XML ao zip
    try:
        zip_file.writestr(xml_name, xml_content)
        zip_file.close()
        zip_buffer.seek(0)
        s3_client.put_object(Bucket=bucket_name, Key=zip_name, Body=zip_buffer.getvalue())
        print(f"Added {xml_name} to {zip_name}")
    except ClientError as e:
        print(f"Error updating zip file in S3: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error updating zip file in S3')
        }

    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }

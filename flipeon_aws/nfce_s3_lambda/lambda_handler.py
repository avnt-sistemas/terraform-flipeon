import boto3
import os
import requests
import json
import multiprocessing

from message_object import message_object

API_URL = os.environ["FLIPEON_API"]
DEST_S3_BUCKET = os.environ["DEST_S3_BUCKET"]

_s3 = None
def get_client():
    global _s3
    if _s3 is None:
        if "LOCALSTACK_HOSTNAME" in os.environ:
            sqs_url = f"http://{os.environ['LOCALSTACK_HOSTNAME']}:4566"
            _s3 = boto3.client("s3", endpoint_url=sqs_url)
        else:
            _s3 = boto3.client("s3")    

    return _s3

def handler(event, context):
    print("API_URL: {0} - DEST_S3_BUCKET: {1}".format(API_URL, DEST_S3_BUCKET))

    queue_files   = []
    for record in event['Records']:
        try:
            record_json = record["body"].replace("'", '"')
            record_dict = json.loads(record_json)
            message_obj = message_object(**record_dict)

            if(message_obj.is_valid()):
                queue_files.append(message_obj)
            else:
                print("objeto inválido: {0}".format(message_obj))
            
        except Exception as ex:
            print("Ocorreu um erro ao processar parte das mensagens: {0}".format(ex))

    success, error = [], []
    with multiprocessing.Pool(multiprocessing.cpu_count() * 4) as pool:
        for arquivo, sucesso in pool.imap(upload_object, queue_files):
            if(sucesso):
                success.append(arquivo)
            else:
                error.append(arquivo)

    try:
        response_body = {"success": success, "error": error}

        requests.post(url = API_URL, data=json.dumps(response_body))
    except Exception as ex:
        print("Ocorreu um erro ao atualizar o estado de integração: {0}".format(ex))

    return {'batchItemFailures': error}

def upload_object(file):
    try:
        s3 = get_client()
        s3.put_object(Body=file.get_file(), Bucket=DEST_S3_BUCKET, Key=f'{file.caminho}/{file.arquivo}.xml')

        return file.arquivo, True
    except Exception as ex:
        print("Ocorreu um erro ao enviar o arquivo para o s3: {0}".format(ex))
        return file.arquivo, False
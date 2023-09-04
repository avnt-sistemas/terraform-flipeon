import boto3
import os
import requests
import json
import concurrent.futures
import multiprocessing

from message_object import message_object

DEST_S3_BUCKET = os.environ["DEST_S3_BUCKET"]
FLIPEON_API = os.environ["FLIPEON_API"]

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

def upload_object(file):
    try:
        s3 = get_client()
        s3.put_object(Body=file.get_file(), Bucket=DEST_S3_BUCKET, Key=f'{file.caminho}/{file.arquivo}.xml')

        return file, True
    except Exception as ex:
        print("Ocorreu um erro ao enviar o arquivo para o s3: {0}".format(ex))
        return file, False

def handler(event, context):
    queue_files = []
    for record in event['Records']:
        try:
            record_json = record["body"].replace("'", '"')
            record_dict = json.loads(record_json)
            message_obj = message_object(**record_dict)

            if(message_obj.is_valid()):
                queue_files.append(message_obj)
            else:
                print("objeto inválido: {0}".format(message_obj))

            if "callback_ip" in record["messageAttributes"]:
                message_obj.callback = record["messageAttributes"]["callback_ip"]["stringValue"]
            else:
                message_obj.callback = FLIPEON_API

            
        except Exception as ex:
            print("Ocorreu um erro ao processar parte das mensagens: {0}".format(ex))

    error = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=multiprocessing.cpu_count() * 4) as executor:
        futures = [executor.submit(upload_object, queue_file) for queue_file in queue_files]
        for future in concurrent.futures.as_completed(futures):
            arquivo, sucesso = future.result()

            response_body = {}
            if(sucesso):
                response_body = {"success": [arquivo.arquivo], "error": []}
            else:
                response_body = {"success": [], "error": [arquivo.arquivo]}
                error.append(arquivo.arquivo)
                
            try:
                url_base = arquivo.callback
                
                api_url = ""
                if(arquivo.acao == "autorizacao"):
                    api_url = os.path.join(url_base, 'v1/callback/nfce-storage')
                else:
                    api_url = os.path.join(url_base, 'v1/callback/nfce-storage-canceled')

                print(url_base, api_url)
                response = requests.post(url = api_url, json=response_body)
            except Exception as ex:
                print("Ocorreu um erro ao atualizar o estado de integração: {0}".format(ex))

    return {'batchItemFailures': error}
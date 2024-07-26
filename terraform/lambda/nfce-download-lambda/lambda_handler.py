import boto3
import os
import zipfile

from message_object import message_object

# Settings
SRC_S3_BUCKET = "nfce-xmls"
DEST_S3_BUCKET = "nfce-download-temporario"
TEMP_FILE = "/tmp/_temp_.zip"

_s3 = None

def get_client():
    global _s3
    if _s3 is None:
        if "LOCALSTACK_HOSTNAME" in os.environ:
            sqs_url = 'http://%s:4566' % os.environ['LOCALSTACK_HOSTNAME']
            _s3 = boto3.client("s3", endpoint_url=sqs_url)
        else:
            _s3 = boto3.client("s3")
    return _s3

def handler(event, context):
    payload_obj = message_object(**event)
    if payload_obj.is_valid():
        with zipfile.ZipFile(TEMP_FILE, "w", compression=zipfile.ZIP_DEFLATED) as zip_file:
            for item in payload_obj.itens:
                key, body = get_object(item)
                if body:
                    key_with_extension = os.path.basename(key) + ".xml"  # Adicionando a extensão .xml
                    zip_file.writestr(key_with_extension, body)

        get_client().upload_file(TEMP_FILE, DEST_S3_BUCKET, f"{payload_obj.key}.zip")
        os.unlink(TEMP_FILE)

        return {'status_code': 200}
    else:
        print("objeto inválido: {0}".format(payload_obj))
        return {'status_code': 400}

def get_object(key):
    try:
        body = get_client().get_object(Bucket=SRC_S3_BUCKET, Key=f"{key}.xml")['Body'].read()
        return key, body
    except Exception as ex:
        print("ocorreu um erro ao recuperar o objeto: {0} - {1}".format(key, ex))
        return key, ""

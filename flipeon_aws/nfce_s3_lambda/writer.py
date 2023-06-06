from tempfile import NamedTemporaryFile
import boto3
import os

class S3Writer:
    def __init__(self, pasta: str, nome_arquivo: str) -> None:
        self.temp_file = NamedTemporaryFile()
        self.key = f"{pasta}/{nome_arquivo}.xml"

        if "LOCALSTACK_HOSTNAME" in os.environ:
            sqs_url = 'http://%s:4566' % os.environ['LOCALSTACK_HOSTNAME']
            self.s3 = boto3.client("s3", endpoint_url=sqs_url)
        else:
            self.s3 = boto3.client("s3")

    # escreve para o arquivo temporário
    def _write_to_file(self, data: str):
        with open(self.temp_file.name, "a") as f:
            f.write(data)
    
    # escreve para o lambda
    def _write_file_to_s3(self):
        self.s3.put_object(Body=self.temp_file, Bucket="nfce-xmls", Key=self.key)

    # escreve para o temporario e para o bucket
    def write(self, data: str):
        self._write_to_file(data=data)
        self._write_file_to_s3()
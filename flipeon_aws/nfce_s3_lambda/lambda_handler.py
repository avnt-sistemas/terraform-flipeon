import json
from writer import S3Writer

def handler(event, context):
    for record in event['Records']:
        payload_json = record["body"].replace("'", '"')
        payload = json.loads(payload_json)

        if("caminho" in payload and "arquivo" in payload and "xml" in payload):
            writer = S3Writer(payload["caminho"], payload["arquivo"])
            writer.write(payload["xml"])

    return {'statusCode': 200}
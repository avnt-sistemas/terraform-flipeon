from writer import S3Writer

# id_conta, ano, mês, PDV.
def handler(event, context):
    writer = S3Writer("teste", "teste")
    writer.write("teste corpo")

    print(event)
    print(context)

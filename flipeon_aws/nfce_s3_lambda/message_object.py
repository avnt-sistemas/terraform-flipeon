from tempfile import NamedTemporaryFile

class message_object(object):
    def __init__(self, acao, caminho, nfce_id, nome_arquivo, xml):
        self.acao = acao
        self.caminho = caminho
        self.nfce_id = nfce_id
        self.nome_arquivo = nome_arquivo
        self.xml = xml

        self.callback = ""

    def is_valid(self) -> bool:
        return self.caminho != "" and self.nfce_id != "" and self.nome_arquivo != "" and self.xml != ""
    
    def get_file(self):
        temp_file = NamedTemporaryFile()
        with open(temp_file.name, "a") as f:
            f.write(self.xml)

        return temp_file

    def get_url(self) -> string:
        api_url, url_base = "", self.callback
                
        if(arquivo.acao == "autorizacao"):
            api_url = os.path.join(url_base, 'v1/callback/nfce-storage')
        else:
            api_url = os.path.join(url_base, 'v1/callback/nfce-storage-canceled')

        return api_url

    def __str__(self) -> str:
        return "caminho: {0} - id: {1} - nome: {2} - valido: {3}".format(self.caminho, self.nfce_id, self.nome_arquivo, self.is_valid())
    
    
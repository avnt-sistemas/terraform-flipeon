from tempfile import NamedTemporaryFile

class message_object(object):
    def __init__(self, url_api, acao, caminho, arquivo, xml):
        self.url_api = url_api
        self.acao    = acao
        self.caminho = caminho
        self.arquivo = arquivo
        self.xml     = xml

    def is_valid(self) -> bool:
        return self.caminho != "" and self.arquivo != "" and self.xml != ""
    
    def get_file(self):
        temp_file = NamedTemporaryFile()
        with open(temp_file.name, "a") as f:
            f.write(self.xml)

        return temp_file

    def __str__(self) -> str:
        return "caminho: {0} - nome: {1} - valido: {2}".format(self.caminho, self.arquivo, self.is_valid())
    
    
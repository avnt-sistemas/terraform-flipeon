class message_object(object):
    def __init__(self, key, itens):
        self.key = key
        self.itens = itens

    def is_valid(self) -> bool:
        return self.key != "" and len(self.itens) != 0

    def __str__(self) -> str:
        print("chave: {0} - itens: {1} - valid: {2}".format(self.key, self.itens, self.is_valid()))
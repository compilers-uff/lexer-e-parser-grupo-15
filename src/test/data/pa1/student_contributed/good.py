class Foo(object):
    x:int = 0
    nome:str = "testando classe"

    def __init__(self:"Foo", nome: str):
        self.nome = nome

    def testando_funcao(x:int):
        print(x)

    def testando_controle():
        for i in 10:
            print(i)

f = Foo("testando construtor classe")
print(f.x)
f.testando_funcao(10)
f.testando_controle(10)

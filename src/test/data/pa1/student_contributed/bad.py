class Foo(object):
    x:int = 0
    nome:str = "testando classe"

    # aqui está errado (1)
    1 2 3

    def testando_aqui_esta_certo(x:int):
        print(x)

if(True):
# aqui está errado (x)
x = 1
    # aqui está errado (INDENT e DEDENT)
    elif: x = 2
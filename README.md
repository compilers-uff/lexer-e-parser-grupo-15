# Projeto de Análise de Indentação em JFlex

## Equipe
- Rodrigo

## Agradecimentos
Agradecimentos ao professor Christiano pelas aulas ministradas, desenvolvedores que criam e debatem em diversos fóruns e threads na web, documentações oficiais do Python e ao projeto CPython cujos materiais serviram de referência, principalmente para a implementação de lógica de indentação no analisador léxico. 
## Tempo de Desenvolvimento
O projeto levou aproximadamente 42 horas para ser concluído.

## Estratégia para Emissão de Tokens INDENT e DEDENT
Para identificar corretamente os tokens INDENT e DEDENT, foi utilizada uma pilha (conforme é sugerido pela própria documentação de Python) para armazenar os níveis de indentação. A cada nova linha, verificamos se a quantidade de espaços aumentou (indicando um INDENT), diminuiu (indicando um ou mais DEDENTs) ou permaneceu igual. O código principal dessa lógica pode ser encontrado no arquivo `ChocoPyLexer.jflex`.

No item 7 do trabalho foram mencionadas 'dicas' com relação a manipulação do INDENT, DEDENT e usar recursos do lexer para manipula-lo com maior granularidade. Com %state%, YYINITAL e métodos yypushback(), yyreset() e também yybegin().

A abordagem detalhada, consiste na utilização de três componentes principais: uma pilha para rastrear os níveis de indentação, um contador para a indentação atual e um sistema de estados para gerenciar o fluxo de análise. A pilha (declarada como ArrayList<Integer>) armazena todos os níveis de indentação encontrados durante a análise. Esta estrutura foi escolhida porque permite acesso eficiente ao último nível (para comparação) e fácil remoção quando um bloco termina.

O contador currIndent acumula os espaços em branco no início de cada linha. Cada espaço incrementa em 1, enquanto tabs contam como 8 espaços - essa decisão reflete as convenções comuns em editores de código. Quando encontramos um caractere não-espaço, ativamos a lógica principal de indentação.

O método auxiliar symbolAtPrevCol foi criado para resolver um problema específico de posicionamento. Quando o lexer encontra o primeiro caractere não-espaço, ele precisa "devolver" esse caractere usando yypushback(1) para processar a indentação primeiro. Porém, isso cria uma discrepância nas posições reportadas, pois yycolumn fica uma posição à frente. symbolAtPrevCol ajusta isso subtraindo 1 da coluna inicial, garantindo que os tokens INDENT/DEDENT apontem para a posição correta no código fonte.

A máquina de estados (YYINITIAL e AFTER) controla quando devemos processar espaços iniciais versus outros tokens. Em YYINITIAL, contamos espaços e gerenciamos indentação. Ao encontrar um token não-espaço, mudamos para AFTER, onde processamos o resto da linha. Quebras de linha nos fazem voltar a YYINITIAL, reiniciando o ciclo.

A emissão de DEDENTs múltiplos é tratada comparando a indentação atual com vários níveis da pilha, emitindo um DEDENT para cada nível excedente. Isso garante que blocos aninhados sejam fechados corretamente. O tratamento especial no final do arquivo (<<EOF>>) assegura que todos os blocos abertos sejam devidamente fechados.

## Relação com a Seção 3.1 do Manual de Referência de ChocoPy
A ideia segue exatamente o que está descrito na seção 3.1 da documentação oficial do ChocoPy, que adota o mesmo comportamento do Python 3. No começo, parece simples: contar espaços no início da linha. Mas há nuances pois é necessário manter o controle do nível de indentação e saber quando um bloco começa ou termina com base só nisso. O funcionamento se baseia em uma pilha de inteiros, começando com zero, que representa os níveis atuais de indentação. A cada nova linha, compara-se o número de espaços com o topo da pilha: se for maior, empilha e gera um token INDENT; se for menor, desempilha e emite DEDENT até chegar ao nível correto. Isso tudo sem perder a ordem dos blocos. No final do arquivo, ainda é preciso desempilhar o que sobrou, emitindo os DEDENT restantes.

Foi criada uma variável chamada currIndent para ir acumulando a quantidade de espaços e tabs no começo de cada linha. A regra é que cada espaço conta 1 e cada tab conta 8 — isso está de acordo com o que o ChocoPy define e também é o padrão em sistemas Unix. A cada nova linha, os caracteres de espaço/tabulação são processados no estado inicial (<YYINITIAL>), e o analisador só muda de estado quando encontra o primeiro caractere "real" (ou seja, não-espaço e não-comentário). Quando isso acontece, uso o yypushback(1) pra jogar o caractere de volta na entrada e disparar a lógica da indentação.

Aqui entra o uso do comando %state, que foi fundamental. Criei dois estados principais no lexer: YYINITIAL, que é o estado padrão de JFlex, e AFTER, que define quando a indentação já foi processada e os tokens normais (identificadores, operadores, palavras-chave, etc.) podem ser reconhecidos. Esse controle por estado foi essencial pra separar a fase de contagem de indentação da fase de leitura dos tokens reais da linguagem. Sem isso, o lexer poderia tentar processar identificadores antes de checar se deveria emitir um INDENT ou DEDENT, o que quebraria a estrutura da AST.

Depois de processar a indentação, o analisador entra no estado AFTER com yybegin(AFTER), e só volta para YYINITIAL quando encontra uma quebra de linha. A quebra é reconhecida por uma regra que, além de mudar o estado de volta para YYINITIAL, também reseta o currIndent com currIndent = 0.

O yypushback() teve um papel importante. Sempre que o lexer encontra o primeiro caractere útil da linha (um identificador, número, símbolo, etc.), ele precisa garantir que esse caractere seja analisado normalmente depois de lidar com a indentação. Então, o que eu faço é empurrar esse caractere de volta com yypushback(1), garantindo que ele será lido de novo na próxima regra. Sem isso, o caractere seria "consumido" antes do lexer mudar de estado, e o token seria perdido.

## Maior Desafio na Implementação (Exceto Indentação)
Fora a indentação, o maior desafio foi entender as dependencias que são fornecidas. Todas as estruturas de Nodes para a geração da AST já eram providas e, portanto, foi necessário a cada nova mudança na criação de Tokens e regras de linguagem "encaixar" a assinatura dos métodos existentes com as subpalavras necessárias. Para encaixar na assinatura de alguns métodos, mais especificamente FuncDef, ClassDef e os métodos para estruturas de controle/repetição (IF, FOR, WHILE) foi necessário 'duplicar' a lógica que retorna os nós mais a esquerda para que sejam retornados, também, os nós mais a direita, o método getRight.
Outra questão foram os testes unitários e a forma como o JSON para a geração da AST era definido. Em alguns casos as regras e tokens estavam 'corretos' mas não batiam exatamente com a estrutura esperada dos testes unitários. O caso mais complicado foi o de teste de construtor de classe, com '__init__'. Essa palavra, no contexto de uma classe define um construtor e, mesmo com essa caracteristica, o lexer nao trata como uma palavra reservada mas sim um indentifier. Eu tomei a decisao de criar uma regra especifica para esse caso mas precisei instanciar um tipo de retorno que era o esperado pela AST. Isso foi totalmente arbitrário e foi necessário debugar o teste unitário em específico.
No geral, foram muitas horas sem desenvolvimento, apenas fazendo esse entendimento do projeto e buscando referencias na Web e em pesquisas. Feito isso, de forma faseada, uma vez que a criação de tokens e regras da linguagem foram realizadas para determinado caso, testava-se tal caso, passando, iria pro próximo e assim por diante. De qualquer forma, sem dúvidas, a parte mais dificil foi a Indentação.

## Referências
- Documentação oficial do Python sobre indentação: [https://docs.python.org/3/reference/lexical_analysis.html#indentation](https://docs.python.org/3/reference/lexical_analysis.html#indentation)
- Código-fonte do CPython (lexer): [https://github.com/python/cpython/blob/main/Parser/lexer/lexer.c](https://github.com/python/cpython/blob/main/Parser/lexer/lexer.c)


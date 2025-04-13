package chocopy.pa1;
import java_cup.runtime.*;
import java.util.ArrayList;
import java.util.Iterator;

%%

/*** Do not change the flags below unless you know what you are doing. ***/

%unicode
%line
%column

%states AFTER

%class ChocoPyLexer
%public

%cupsym ChocoPyTokens
%cup
%cupdebug

%eofclose false

/*** Do not change the flags above unless you know what you are doing. ***/

/* The following code section is copied verbatim to the
 * generated lexer class. */
%{
    /* The code below includes some convenience methods to create tokens
     * of a given type and optionally a value that the CUP parser can
     * understand. Specifically, a lot of the logic below deals with
     * embedded information about where in the source code a given token
     * was recognized, so that the parser can report errors accurately.
     * (It need not be modified for this project.) */

    /** Producer of token-related values for the parser. */
    final ComplexSymbolFactory symbolFactory = new ComplexSymbolFactory();

    /** Return a terminal symbol of syntactic category TYPE and no
     *  semantic value at the current source location. */
    private Symbol symbol(int type) {
        return symbol(type, yytext());
    }

    /** Return a terminal symbol of syntactic category TYPE and semantic
     *  value VALUE at the current source location. */
    private Symbol symbol(int type, Object value) {
        return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[type], type,
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn + 1),
            new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
            value);
    }

    private Symbol symbolAtPrevCol(int type, Object value) {
        return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[type], type,
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn - 1),
            new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
            value);
    }

    private int currIndent = 0;

    private ArrayList<Integer> stack = new ArrayList<Integer>();

    private void push(int indent){
        stack.add(indent);
    }

    private int pop(){
        if(stack.isEmpty()) return 0;
        return stack.remove(stack.size() - 1);
    }

    private int top(){
        if(stack.isEmpty()) return 0;
        return stack.get(stack.size() - 1);
    }

%}

/* Macros (regexes used in rules below) */

WhiteSpace = [ \t]
LineBreak  = \r|\n|\r\n
Identifier = [a-zA-Z$_][a-zA-Z0-9$_]*
IntegerLiteral = 0 | [1-9][0-9]*
StringLiteral = \"([^\"\\]|\\.)*\" 
Comments = #[^\r\n]*



%%

<YYINITIAL>{
  {WhiteSpace} { currIndent += yytext().equals("\t") ? 8 : 1; }
  
  {LineBreak}  { currIndent = 0; }

  {Comments}   { /* ignore */ }
  /* Comentários detalhados da implementacao de indentação no readme do projeto */
  [^ \t\r\n#] {
      yypushback(1);
      if (top() > currIndent) {
          pop();
          return symbolAtPrevCol(top() < currIndent ? ChocoPyTokens.UNRECOGNIZED : ChocoPyTokens.DEDENT, currIndent);
      }
      yybegin(AFTER);
      if (top() < currIndent) {
          push(currIndent);
          return symbolAtPrevCol(ChocoPyTokens.INDENT, currIndent);
      }
  }
}

<AFTER> {
  {LineBreak} { yybegin(YYINITIAL); currIndent = 0; return symbol(ChocoPyTokens.NEWLINE); }

  /* Literals. */
  {IntegerLiteral}               { return symbol(ChocoPyTokens.NUMBER, Integer.parseInt(yytext())); }

  {StringLiteral}                { return symbol(ChocoPyTokens.STRING, yytext().substring(1, yytext().length() - 1)); }

  "False"                        { return symbol(ChocoPyTokens.BOOL, false); }
  "True"                         { return symbol(ChocoPyTokens.BOOL, true); }
  "None"                         { return symbol(ChocoPyTokens.NONE); }

  ","                            { return symbol(ChocoPyTokens.COMMA); }


  /* Operators. */
  "+"                         { return symbol(ChocoPyTokens.PLUS); }
  "-"                         { return symbol(ChocoPyTokens.MINUS); }
  "("                         { return symbol(ChocoPyTokens.LPAR); }
  ")"                         { return symbol(ChocoPyTokens.RPAR); }
  "="                         { return symbol(ChocoPyTokens.ASSIGN); }
  "*"                         { return symbol(ChocoPyTokens.MUL); }  
  "/"                         { return symbol(ChocoPyTokens.DIV); }
  "%"                         { return symbol(ChocoPyTokens.MOD); }
  "["                         { return symbol(ChocoPyTokens.LBR); }
  "]"                         { return symbol(ChocoPyTokens.RBR); }
  "=="                        { return symbol(ChocoPyTokens.EQUAL); }
  "!="                        { return symbol(ChocoPyTokens.NEQ); }
  ">="                        { return symbol(ChocoPyTokens.GEQ); }
  "<="                        { return symbol(ChocoPyTokens.LEQ); }
  ">"                         { return symbol(ChocoPyTokens.GT); }
  "<"                         { return symbol(ChocoPyTokens.LT); }
  "if"                        { return symbol(ChocoPyTokens.IF); }
  "else"                      { return symbol(ChocoPyTokens.ELSE); }
  "or"                        { return symbol(ChocoPyTokens.OR); }
  "not"                       { return symbol(ChocoPyTokens.NOT); }
  "."                         { return symbol(ChocoPyTokens.DOT); }
  "and"                       { return symbol(ChocoPyTokens.AND); }
  "def"                       { return symbol(ChocoPyTokens.DEF); }
  ":"                         { return symbol(ChocoPyTokens.COLON); }
  "global"                    { return symbol(ChocoPyTokens.GLOBAL); }
  "nonlocal"                  { return symbol(ChocoPyTokens.NONLOCAL); }
  "->"                        { return symbol(ChocoPyTokens.ARROW); }
  "return"                    { return symbol(ChocoPyTokens.RETURN); }
  "class"                     { return symbol(ChocoPyTokens.CLASS); }
  "elif"                      { return symbol(ChocoPyTokens.ELIF); }
  "while"                     { return symbol(ChocoPyTokens.WHILE); }
  "pass"                      { return symbol(ChocoPyTokens.PASS); }
  "for"                       { return symbol(ChocoPyTokens.FOR); }
  "in"                        { return symbol(ChocoPyTokens.IN); }
  "is"                        { return symbol(ChocoPyTokens.IS); }

  /* Identifier */
  {Identifier}                { return symbol(ChocoPyTokens.ID, yytext()); }  

  /* Whitespace. */
  {WhiteSpace}                { /* ignore */ }

  {Comments}                  { /* ignore */ }
}

<<EOF>> { return !stack.isEmpty() ? symbol(ChocoPyTokens.DEDENT, pop()) : symbol(ChocoPyTokens.EOF); }

/* Error fallback. */
[^]                           { return symbol(ChocoPyTokens.UNRECOGNIZED); }

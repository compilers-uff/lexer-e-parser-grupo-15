package chocopy.pa1;
import java_cup.runtime.*;

%%

/*** Do not change the flags below unless you know what you are doing. ***/

%unicode
%line
%column

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

%}

/* Macros (regexes used in rules below) */

WhiteSpace = [ \t]
LineBreak  = \r|\n|\r\n
Identifier = [a-zA-Z$_][a-zA-Z0-9$_]*
IntegerLiteral = 0 | [1-9][0-9]*
StringLiteral = \"([^\"\\]|\\.)*\" 



%%


<YYINITIAL> {

  /* Delimiters. */
  {LineBreak}                    { return symbol(ChocoPyTokens.NEWLINE); }

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
  "and"                          { return symbol(ChocoPyTokens.AND); }

  /* Identifier */
  {Identifier}                { return symbol(ChocoPyTokens.ID, yytext()); }  

  /* Whitespace. */
  {WhiteSpace}                { /* ignore */ }
}

<<EOF>>                       { return symbol(ChocoPyTokens.EOF); }

/* Error fallback. */
[^]                           { return symbol(ChocoPyTokens.UNRECOGNIZED); }

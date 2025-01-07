%{
#include "parserGo.tab.h"
#include <stdlib.h>
void yyerror(const char *s);
%}

%%
"int"        return INT;
"return"     return RETURN;
"if"         return IF;
"else"       return ELSE;
"for"      return FOR;
"struct"     return STRUCT;
"fmt.Print"        return PRINT;
"fmt.Scan"       return SCAN;
"bool"       return BOOL;
"char"       return CHAR;
"float64"     return FLOAT;
"break"       return BREAK;
"continue"    return CONTINUE;
"func"        return FUNC;
"fmt.Println"     return PRINTLN;
"fmt.Printf"      return PRINTF;
"math.Sqrt"     return SQRT;
"var"         return VAR;
"package"     return PACKAGE;
"import"      return IMPORT;

"{"          return LBRACE;
"}"          return RBRACE;
"("          return LPAREN;
")"          return RPAREN;
"["          return LBRACK;
"]"          return RBRACK;


"+"           return PLUS;
"-"           return MINUS;
"*"           return MUL;
"/"           return DIV;
"%"           return MOD;
"="           return ASSIGN;
"=="          return EQ;
"!="          return NEQ;
"<"           return LT;
"<="          return LTE;
">"           return GT;
">="          return GTE;
"&&"          return AND;
"||"          return OR;
"++"          return INC;
"--"          return DEC;
"+="	    return ASSIGN_OP_PLUS;
"-="	    return ASSIGN_OP_MINUS;
"*="	    return ASSIGN_OP_MUL;
"/="	    return ASSIGN_OP_DIV;
"%="	    return ASSIGN_OP_MOD;
":="          return SHORTDECL;
"&"          return ADDRESSOF;
";"             return SEMICOLON;
","	     return COMMA;
[0-9]+       { yylval = atoi(yytext); return INT_CONST; }
\"[^\"]*\"   { return STRING_LITERAL; }

[a-zA-Z_.][a-zA-Z0-9_.]* {return IDENTIFIER;}

<<EOF>>                  {return END_OF_FILE;}

[ \t\n]+     ; /* Ignore whitespace */

.            { yyerror("Unexpected character"); }

%%

int yywrap() {
    return 1;
}



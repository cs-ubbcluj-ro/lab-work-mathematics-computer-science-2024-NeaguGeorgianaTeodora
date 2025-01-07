%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int yydebug; // Declaration of yydebug

void yyerror(const char *s);

// We'll track which productions are used
int productions_used[1000];
int prod_count = 0;

// A macro to record a production number
#define RECORD_PRODUCTION(num) \
    do { \
        productions_used[prod_count++] = (num); \
    } while (0)
%}

/* Tokens */
%token END_OF_FILE
%token IDENTIFIER INT_CONST
%token FLOAT CHAR BOOL INT 
%token STRING_LITERAL

%token BREAK CONTINUE FUNC PRINTLN PRINT PRINTF SCAN SQRT
%token IF ELSE FOR STRUCT VAR PACKAGE RETURN IMPORT

%token PLUS MINUS MUL DIV MOD ASSIGN EQ NEQ LT LTE GT GTE AND OR INC DEC SHORTDECL ADDRESSOF
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK SEMICOLON COMMA
%token ASSIGN_OP_MINUS ASSIGN_OP_MUL ASSIGN_OP_DIV ASSIGN_OP_MOD ASSIGN_OP_PLUS

/* Precedence and associativity */
%right ASSIGN SHORTDECL        // '=' and ':='
%left OR                       // '||'
%left AND                      // '&&'
%nonassoc EQ NEQ LT LTE GT GTE
%left PLUS MINUS
%left MUL DIV MOD
%nonassoc ELSE

%%
/* 1: program -> package_decl import_decl_list func_list */
program: package_decl import_decl_list func_list 
{
    RECORD_PRODUCTION(1);
    printf("Program syntactic correct\n");
    printf("Productions used: ");
    for (int i = 0; i < prod_count; i++) {
        printf("%d ", productions_used[i]);
    }
    printf("\n");
}
;

/* 2: package_decl -> PACKAGE IDENTIFIER */
package_decl : PACKAGE IDENTIFIER
{
    RECORD_PRODUCTION(2);
}
;

/* 3: import_decl_list -> ε
       | import_decl_list import_decl */
import_decl_list:
    /* empty */
  | import_decl_list import_decl
{
    RECORD_PRODUCTION(3);
}
;

/* 4: import_decl -> IMPORT STRING_LITERAL
   5: import_decl -> IMPORT LPAREN import_spec_list RPAREN */
import_decl:
    IMPORT STRING_LITERAL
{
    RECORD_PRODUCTION(4);
}
  | IMPORT LPAREN import_spec_list RPAREN
{
    RECORD_PRODUCTION(5);
}
;

/* 6: import_spec_list -> STRING_LITERAL
   7: import_spec_list -> import_spec_list STRING_LITERAL */
import_spec_list:
    STRING_LITERAL
{
    RECORD_PRODUCTION(6);
}
  | import_spec_list STRING_LITERAL
{
    RECORD_PRODUCTION(7);
}
;

/* 8: var_decl -> VAR IDENTIFIER type */
var_decl:
    VAR IDENTIFIER type
{
    RECORD_PRODUCTION(8);
}
;

/* 9: short_var_decl -> IDENTIFIER := expression */
short_var_decl:
    IDENTIFIER SHORTDECL expression
{
    RECORD_PRODUCTION(9);
}
;

/* 10: type -> INT
   11: type -> FLOAT
   12: type -> CHAR
   13: type -> BOOL */
type:
    INT
{
    RECORD_PRODUCTION(10);
}
  | FLOAT
{
    RECORD_PRODUCTION(11);
}
  | CHAR
{
    RECORD_PRODUCTION(12);
}
  | BOOL
{
    RECORD_PRODUCTION(13);
}
;

func_list:
	| func_decl
{
    RECORD_PRODUCTION(14);
}

	| func_list func_decl
{
    RECORD_PRODUCTION(15);
}
;

/* 16: func_decl -> FUNC IDENTIFIER LPAREN param_list RPAREN block
   17: func_decl -> FUNC IDENTIFIER LPAREN param_list RPAREN type block
   18: func_decl -> FUNC IDENTIFIER LPAREN param_list RPAREN LPAREN type_list RPAREN block */
func_decl:
      FUNC IDENTIFIER LPAREN param_list RPAREN block
{
    RECORD_PRODUCTION(16);
}
    | FUNC IDENTIFIER LPAREN param_list RPAREN type block
{
    RECORD_PRODUCTION(17);
}
    | FUNC IDENTIFIER LPAREN param_list RPAREN LPAREN type_list RPAREN block
{
    RECORD_PRODUCTION(18);
}
;

/* 19: type_list -> type
   20: type_list -> type_list COMMA type */
type_list:
    type
{
    RECORD_PRODUCTION(19);
}
  | type_list COMMA type
{
    RECORD_PRODUCTION(20);
}
;

/* 21: param_list -> ε
       | param_list COMMA IDENTIFIER type 
     22: param_list -> IDENTIFIER type
*/
param_list:
    /* empty */
  | param_list COMMA IDENTIFIER type
{
    RECORD_PRODUCTION(21);
}
| IDENTIFIER type
{
    RECORD_PRODUCTION(22);
}
;

/* 23: block -> LBRACE statement_list RBRACE */
block:
    LBRACE statement_list RBRACE
{
    RECORD_PRODUCTION(23);
}
;

/* 24: statement_list -> ε
       | statement_list statement */
statement_list:
    /* empty */
  | statement_list statement
{
    RECORD_PRODUCTION(24);
}
;

/* 25: statement -> simple_stmt
   26: statement -> block
   27: statement -> short_var_decl
   28: statement -> var_decl
   29: statement -> print_stmt
   30: statement -> scan_stmt
   31: statement -> for_stmt
   32: statement -> if_stmt 
   33: statement -> return_stmt 
*/
statement:
    simple_stmt
{
    RECORD_PRODUCTION(25);
}
  | block
{
    RECORD_PRODUCTION(26);
}
  | short_var_decl
{
    RECORD_PRODUCTION(27);
}
  | var_decl
{
    RECORD_PRODUCTION(28);
}
  | print_stmt
{
    RECORD_PRODUCTION(29);
}
  | scan_stmt
{
    RECORD_PRODUCTION(30);
}
  | for_stmt
{
    RECORD_PRODUCTION(31);
}
  | if_stmt
{
    RECORD_PRODUCTION(32);
}
  | return_stmt
{
    RECORD_PRODUCTION(33);
}
;

/* 34: simple_stmt -> expression
   35: simple_stmt -> assignment */
simple_stmt:
    expression
{
    RECORD_PRODUCTION(34);
}
  | assignment
{
    RECORD_PRODUCTION(35);
}
;

/* 36: assignment -> IDENTIFIER ASSIGN expression */
assignment:
    IDENTIFIER ASSIGN expression
{
    RECORD_PRODUCTION(36);
}
;

/* 37: expression -> unary_expr
   38: expression -> expression OR expression
   39: expression -> expression AND expression
   40: expression -> expression EQ expression
   41: expression -> expression NEQ expression
   42: expression -> expression LT expression
   43: expression -> expression LTE expression
   44: expression -> expression GT expression
   45: expression -> expression GTE expression
   46: expression -> expression PLUS expression
   47: expression -> expression MINUS expression
   48: expression -> expression MUL expression
   49: expression -> expression DIV expression
   50: expression -> expression MOD expression 
   51: expression-> INT ( math.Sqrt ( IDENTIFIER  )) 

*/
expression:
    unary_expr
{
    RECORD_PRODUCTION(37);
}
  | expression OR expression
{
    RECORD_PRODUCTION(38);
}
  | expression AND expression
{
    RECORD_PRODUCTION(39);
}
  | expression EQ expression
{
    RECORD_PRODUCTION(40);
}
  | expression NEQ expression
{
    RECORD_PRODUCTION(41);
}
  | expression LT expression
{
    RECORD_PRODUCTION(42);
}
  | expression LTE expression
{
    RECORD_PRODUCTION(43);
}
  | expression GT expression
{
    RECORD_PRODUCTION(44);
}
  | expression GTE expression
{
    RECORD_PRODUCTION(45);
}
  | expression PLUS expression
{
    RECORD_PRODUCTION(46);
}
  | expression MINUS expression
{
    RECORD_PRODUCTION(47);
}
  | expression MUL expression
{
    RECORD_PRODUCTION(48);
}
  | expression DIV expression
{
    RECORD_PRODUCTION(49);
}
  | expression MOD expression
{
    RECORD_PRODUCTION(50);
}
  | INT LPAREN SQRT LPAREN IDENTIFIER  RPAREN RPAREN
{
    RECORD_PRODUCTION(51);
}

;

/* 52: unary_expr -> IDENTIFIER
   53: unary_expr -> ADDRESSOF unary_expr
   54: unary_expr -> INT_CONST
   55: unary_expr -> STRING_LITERAL */
unary_expr:
    IDENTIFIER
{
    RECORD_PRODUCTION(52);
}
  | ADDRESSOF unary_expr
{
    RECORD_PRODUCTION(53);
}
  | INT_CONST
{
    RECORD_PRODUCTION(54);
}
  | STRING_LITERAL
{
    RECORD_PRODUCTION(55);
}
;

/* 56: print_stmt -> PRINT LPAREN expression_list RPAREN
   57: print_stmt -> PRINTLN LPAREN expression_list RPAREN
   58: print_stmt -> PRINTF LPAREN expression_list RPAREN */
print_stmt:
    PRINT LPAREN expression_list RPAREN
{
    RECORD_PRODUCTION(56);
}
  | PRINTLN LPAREN expression_list RPAREN
{
    RECORD_PRODUCTION(57);
}
  | PRINTF LPAREN expression_list RPAREN
{
    RECORD_PRODUCTION(58);
}
;

/* 59: scan_stmt -> SCAN LPAREN expression_list RPAREN */
scan_stmt:
    SCAN LPAREN expression_list RPAREN
{
    RECORD_PRODUCTION(59);
}
;

/*  expression_list -> ε
   60: expression_list -> expression
   61: expression_list -> expression_list COMMA expression */
expression_list:
    /* empty */
  | expression
{
    RECORD_PRODUCTION(60);
}
  | expression_list COMMA expression
{
    RECORD_PRODUCTION(61);
}
;

/* 62: for_stmt -> FOR short_var_decl SEMICOLON condition SEMICOLON post_stmt block */
for_stmt:
    FOR short_var_decl SEMICOLON condition SEMICOLON post_stmt block
{
    RECORD_PRODUCTION(62);
}
;

/* 
   63: condition -> expression AND expression
   64: condition -> expression EQ expression
   65: condition -> expression NEQ expression
   66: condition -> expression LT expression
   67: condition -> expression LTE expression
   68: condition -> expression GT expression
   69: condition -> expression GTE expression
   70: condition-> IDENTIFIER LPAREN arg_list RPAREN
   71: condition -> expression OR expression
 */
condition:
  | expression AND expression
{
    RECORD_PRODUCTION(63);
}
  | expression EQ expression
{
    RECORD_PRODUCTION(64);
}
  | expression NEQ expression
{
    RECORD_PRODUCTION(65);
}
  | expression LT expression
{
    RECORD_PRODUCTION(66);
}
  | expression LTE expression
{
    RECORD_PRODUCTION(67);
}
  | expression GT expression
{
    RECORD_PRODUCTION(68);
}
  | expression GTE expression
{
    RECORD_PRODUCTION(69);
}
  |  IDENTIFIER LPAREN arg_list RPAREN
{
    RECORD_PRODUCTION(70);
}
  |  expression OR expression
{
    RECORD_PRODUCTION(71);
}

;

 arg_list:
	/* empty */ 
| arg_list COMMA IDENTIFIER
{
    RECORD_PRODUCTION(72);
}
| IDENTIFIER
{
    RECORD_PRODUCTION(73);
}

/* 74: post_stmt -> IDENTIFIER DEC
   75: post_stmt -> IDENTIFIER ASSIGN_OP_PLUS expression
   76: post_stmt -> IDENTIFIER ASSIGN_OP_MINUS expression
   77: post_stmt -> IDENTIFIER ASSIGN_OP_MUL expression
   78: post_stmt -> IDENTIFIER ASSIGN_OP_DIV expression
   79: post_stmt -> IDENTIFIER ASSIGN_OP_MOD expression 
   80: post_stmt -> IDENTIFIER INC
*/
post_stmt:
  | IDENTIFIER DEC
{
    RECORD_PRODUCTION(74);
}
  | IDENTIFIER ASSIGN_OP_PLUS expression
{
    RECORD_PRODUCTION(75);
}
  | IDENTIFIER ASSIGN_OP_MINUS expression
{
    RECORD_PRODUCTION(76);
}
  | IDENTIFIER ASSIGN_OP_MUL expression
{
    RECORD_PRODUCTION(77);
}
  | IDENTIFIER ASSIGN_OP_DIV expression
{
    RECORD_PRODUCTION(78);
}
  | IDENTIFIER ASSIGN_OP_MOD expression
{
    RECORD_PRODUCTION(79);
}
   | IDENTIFIER INC
{
    RECORD_PRODUCTION(80);
}
;

/* 81: if_stmt -> IF condition block */
if_stmt:
    IF condition block
{
    RECORD_PRODUCTION(81);
}
;

/* 82: return_stmt -> RETURN IDENTIFIER */
return_stmt:
RETURN IDENTIFIER
{
    RECORD_PRODUCTION(82);
}
;

%%

/* Standard error reporting function */
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    exit(1);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("fopen");
            return 1;
        }
    } else {
        yyin = stdin;
    }

    if (yyparse() == 0) {
        printf("Parsing completed successfully\n");
    }
    return 0;
}






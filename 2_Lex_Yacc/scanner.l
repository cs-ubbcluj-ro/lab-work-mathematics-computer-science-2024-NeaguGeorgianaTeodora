%{
#include <string.h>
#include <stdio.h>

typedef struct {
    char token[257];
    int symbolTableCode;
} PIF;

typedef struct {
    char token[257];
    int index;
} ST;

ST SymbolTable[100];
int stLength = 0;

PIF ProgramInternalForm[300];
int pifLength = 0;

int errorFound = 0;
int lineNumber = 1;

/* Function Definition */
int addToSymbolTable(char* token);
void addToProgramInternalForm(char* token, int stCode);
void showSymbolTable();
void showProgramInternalForm();

/* Functions */

int addToSymbolTable(char* token) {
    for(int i = 0; i < stLength; i++) {
        if(strcmp(SymbolTable[i].token, token) == 0) {
            return SymbolTable[i].index;
        }
    }
    /* if the token is not found in the symbol table, the function adds the new token at the end of the table */

    strcpy(SymbolTable[stLength].token, token); /* copies the token to the symbol table */
    SymbolTable[stLength].index = stLength;
    stLength++;
    return stLength - 1; /* returns the index of the newly added token */
}

void addToProgramInternalForm(char* token, int stCode) {
    strcpy(ProgramInternalForm[pifLength].token, token);
    ProgramInternalForm[pifLength].symbolTableCode = stCode;
    pifLength++;
} /* adds a new token to the program internal form */   

void showSymbolTable() {
    printf("--------------- ST ---------------\n");
    for(int i = 0; i < stLength; i++) {
        printf(" %s  %d\n", SymbolTable[i].token, SymbolTable[i].index);
        printf("------------------------------\n");
    }
    printf("\n\n");
}

void showProgramInternalForm() {
    printf("--------------- PIF ----------------\n");
    for(int i = 0; i < pifLength; i++) {
        printf(" %s  %d\n", ProgramInternalForm[i].token, ProgramInternalForm[i].symbolTableCode);
        printf("------------------------------\n");
    }
}

%}

IDENTIFIER [a-zA-Z][a-zA-Z0-9_]*
NUMBER     [+-]?(0|[1-9][0-9]*)
STRING     \"(\\.|[^\"\\])*\"

/*** Rule Section ***/
%%
break                                    { addToProgramInternalForm(yytext, -1); }
case                                     { addToProgramInternalForm(yytext, -1); }
else                                     { addToProgramInternalForm(yytext, -1); }
const                                    { addToProgramInternalForm(yytext, -1); }
if                                       { addToProgramInternalForm(yytext, -1); }
continue                                 { addToProgramInternalForm(yytext, -1); }
slmgr /atomap                                      { addToProgramInternalForm(yytext, -1); }
package                                  { addToProgramInternalForm(yytext, -1); }
return                                   { addToProgramInternalForm(yytext, -1); }
for                                      { addToProgramInternalForm(yytext, -1); }
func                                     { addToProgramInternalForm(yytext, -1); }
struct                                   { addToProgramInternalForm(yytext, -1); }
switch                                   { addToProgramInternalForm(yytext, -1); }
type                                     { addToProgramInternalForm(yytext, -1); }
import                                   { addToProgramInternalForm(yytext, -1); }
int                                      { addToProgramInternalForm(yytext, -1); }
Println                                  { addToProgramInternalForm(yytext, -1); }
float64                                  { addToProgramInternalForm(yytext, -1); }
Print                                    { addToProgramInternalForm(yytext, -1); }
char                                     { addToProgramInternalForm(yytext, -1); }
Scan                                     { addToProgramInternalForm(yytext, -1); }
bool                                     { addToProgramInternalForm(yytext, -1); }
Printf                                   { addToProgramInternalForm(yytext, -1); }
var                                      { addToProgramInternalForm(yytext, -1); }
main                                     { addToProgramInternalForm(yytext, -1); }
[=+\-*/%&]                                { addToProgramInternalForm(yytext, -1); }
[<>=!]=?                                 { addToProgramInternalForm(yytext, -1); }
[\(\)\{\};,.]                             { addToProgramInternalForm(yytext, -1); }

{IDENTIFIER}                             { int stCode = addToSymbolTable(yytext); addToProgramInternalForm(yytext, stCode); }
{NUMBER}                                 { int stCode = addToSymbolTable(yytext); addToProgramInternalForm(yytext, stCode); }
{STRING}                                 { int stCode = addToSymbolTable(yytext); addToProgramInternalForm(yytext, stCode); }
[\n]                                     { ++lineNumber; }
[ \t\n]+                                 { /* eat up whitespace */ }
.                                        { errorFound = 1; printf("Illegal token %s at line %d\n", yytext, lineNumber); }
%%

/* yywrap() - wraps the above rule section */
int yywrap() {}

int main(int argc, char** argv) {
    FILE *fp;
    if (argc < 2) {
        printf("provide a file .\n");
        return 1;
    }

    fp = fopen(argv[1], "r");
    if (!fp) {
        printf("mission failed %s.\n", argv[1]);
        return 1;
    }
    
    yyin = fp;
    yylex();

    if (errorFound == 0) {
        showSymbolTable();
        showProgramInternalForm();
    }

    fclose(fp);
    return 0;
}

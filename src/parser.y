%{
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern int32_t line_num;   /* declared in scanner.l */
extern char buffer[512];  /* declared in scanner.l */
extern FILE *yyin;        /* declared by lex */
extern char *yytext;      /* declared by lex */

extern int yylex(void); 
static void yyerror(const char *msg);
%}

%start program_name
%token ID_TER BEGIN_TER END_TER VAR_TER OF_TER IF_TER ELSE_TER THEN_TER FOR_TER WHILE_TER PRINT_TER TO_TER RETURN_TER
%token MOD_TER ASSIGN_TER LESS_TER LESSEQUAL_TER ISEQUAL_TER LARGEREQUAL_TER LARGER_TER EQUAL_TER AND_TER OR_TER NOT_TER
%token ARR_TER BOOL_TER INT_TER STR_TER REAL_TER
%token DEF_TER DO_TER TRUE_TER FALSE_TER READ_TER STRING_TER CONSTINT_TER CONSTNOTINT_TER
%token ',' ';' ':' '(' ')' '[' ']'
%left '+' '-' '*' '/'


%%

program_name: ID_TER ';' vari func compound END_TER ;

empty: ;

func: func_decdef func | empty;
func_decdef: ID_TER '(' arg ')' ':' scalar_type ';' | ID_TER '(' arg ')' ';' | 
             ID_TER '(' arg ')' ':' scalar_type compound END_TER | ID_TER '(' arg ')' compound END_TER ;
arg: id_list ':' scalar_type | empty;
id_list: ID_TER id_list2 ;
id_list2: ',' ID_TER id_list2 | empty; 
scalar_type: BOOL_TER | INT_TER | STR_TER | REAL_TER ;
const: CONSTINT_TER | CONSTNOTINT_TER ;
nega_const: '-' const;
operator: '-' | '*' | '/' | MOD_TER | '+' | LESS_TER | LESSEQUAL_TER | 
          ISEQUAL_TER | LARGEREQUAL_TER | LARGER_TER | EQUAL_TER | AND_TER | OR_TER ;
booleanvalue: TRUE_TER | FALSE_TER;

vari: VAR_TER id_list ':' scalar_type ';' vari |
      VAR_TER id_list ':' array_declare array_declare2 scalar_type ';' vari |
      VAR_TER id_list ':' const ';' vari | 
      VAR_TER id_list ':' STRING_TER ';' vari | 
      VAR_TER id_list ':' booleanvalue ';' vari | empty;
array_declare: ARR_TER CONSTINT_TER OF_TER ;
array_declare2: ARR_TER CONSTINT_TER OF_TER array_declare2 | empty;

compound: BEGIN_TER vari stmt END_TER | empty;
compound_stmt: BEGIN_TER vari stmt END_TER ;
stmt: simple_stmt stmt | cond_stmt stmt | while_stmt stmt | for_stmt stmt | 
      return_stmt | pro_call ';' stmt | compound_stmt stmt | empty ;

simple_stmt: var_ref ASSIGN_TER isnot expression ';' |
        PRINT_TER expression ';' |
        READ_TER var_ref ';' ;
var_ref: ID_TER arr_ref ;
arr_ref: '[' expression ']' arr_ref | empty;

cond_stmt: IF_TER expression THEN_TER compound ELSE_TER compound END_TER IF_TER |
           IF_TER expression THEN_TER compound END_TER IF_TER ;

while_stmt: WHILE_TER isnot expression DO_TER compound END_TER DO_TER ;
isnot: NOT_TER | empty ;

for_stmt: FOR_TER ID_TER ASSIGN_TER CONSTINT_TER TO_TER CONSTINT_TER DO_TER compound END_TER DO_TER ;

return_stmt: RETURN_TER expression ';' ;

pro_call: ID_TER pro_call2 ;
pro_call2: '(' expression expression2 ')' | '(' ')'

expression: const expression3 | var_ref expression3 | pro_call expression3 | STRING_TER expression3 | pro_call2 expression3 | nega_const expression3;
expression2: ',' expression expression2 | empty;
expression3: operator const expression3 | operator var_ref expression3 | operator pro_call expression3 | 
             operator pro_call2 expression3 | operator STRING_TER expression3 | operator nega_const | empty ;


%%

void yyerror(const char *msg) {
    fprintf(stderr,
            "\n"
            "|-----------------------------------------------------------------"
            "---------\n"
            "| Error found in Line #%d: %s\n"
            "|\n"
            "| Unmatched token: %s\n"
            "|-----------------------------------------------------------------"
            "---------\n",
            line_num, buffer, yytext);
    exit(-1);
}

int main(int argc, const char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: ./parser <filename>\n");
        exit(-1);
    }

    yyin = fopen(argv[1], "r");
    assert(yyin != NULL && "fopen() fails.");

    yyparse();

    printf("\n"
           "|--------------------------------|\n"
           "|  There is no syntactic error!  |\n"
           "|--------------------------------|\n");
    return 0;
}

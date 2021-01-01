%{
#include <stdint.h>

#include "parser.h"

#define LIST                strCat(yytext)
#define TOKEN(t)            { LIST; if (opt_tok) printf("<%s>\n", #t); }
#define TOKEN_CHAR(t)       { LIST; if (opt_tok) printf("<%c>\n", (t)); }
#define TOKEN_STRING(t, s)  { LIST; if (opt_tok) printf("<%s: %s>\n", #t, (s)); }
#define MAX_LINE_LENG       512

uint32_t line_num = 1;
char buffer[MAX_LINE_LENG];

static int32_t opt_src = 1;
static int32_t opt_tok = 1;
static char string_literal[MAX_LINE_LENG];
static char *buffer_ptr = buffer;

static void strCat(const char *Text);

%}

integer 0|[1-9][0-9]*
float {integer}\.(0|[0-9]*[1-9])

%x CCOMMENT

%%
    /* Delimiter */
"," { TOKEN_CHAR(','); return ',';}
";" { TOKEN_CHAR(';'); return ';';}
":" { TOKEN_CHAR(':'); return ':';}
"(" { TOKEN_CHAR('('); return '(';}
")" { TOKEN_CHAR(')'); return ')';}
"[" { TOKEN_CHAR('['); return '[';}
"]" { TOKEN_CHAR(']'); return ']';}


    /* Operator */
"+"   { TOKEN_CHAR('+'); return '+';}
"-"   { TOKEN_CHAR('-'); return '-';}
"*"   { TOKEN_CHAR('*'); return '*';}
"/"   { TOKEN_CHAR('/'); return '/';}
"mod" { TOKEN(mod); return MOD_TER;}
":="  { TOKEN(:=); return ASSIGN_TER;}
"<"   { TOKEN_CHAR('<'); return LESS_TER;}
"<="  { TOKEN(<=); return LESSEQUAL_TER;}
"<>"  { TOKEN(<>); return ISEQUAL_TER;}
">="  { TOKEN(>=); return LARGEREQUAL_TER;}
">"   { TOKEN_CHAR('>'); return LARGER_TER;}
"="   { TOKEN_CHAR('='); return EQUAL_TER;}
"and" { TOKEN(and); return AND_TER;}
"or"  { TOKEN(or); return OR_TER;}
"not" { TOKEN(not); return NOT_TER;}

    /* Keyword */
"array"   { TOKEN(KWarray); return ARR_TER;}
"begin"   { TOKEN(KWbegin); return BEGIN_TER;}
"boolean" { TOKEN(KWboolean); return BOOL_TER;}
"def"     { TOKEN(KWdef); return DEF_TER;}
"do"      { TOKEN(KWdo); return DO_TER;}
"else"    { TOKEN(KWelse); return ELSE_TER;}
"end"     { TOKEN(KWend); return END_TER;}
"false"   { TOKEN(KWfalse); return FALSE_TER;}
"for"     { TOKEN(KWfor); return FOR_TER;}
"integer" { TOKEN(KWinteger); return INT_TER;}
"if"      { TOKEN(KWif); return IF_TER;}
"of"      { TOKEN(KWof); return OF_TER;}
"print"   { TOKEN(KWprint); return PRINT_TER;}
"read"    { TOKEN(KWread); return READ_TER;}
"real"    { TOKEN(KWreal); return REAL_TER;}
"string"  { TOKEN(KWstring); return STR_TER;}
"then"    { TOKEN(KWthen); return THEN_TER;}
"to"      { TOKEN(KWto); return TO_TER;}
"true"    { TOKEN(KWtrue); return TRUE_TER;}
"return"  { TOKEN(KWreturn); return RETURN_TER;}
"var"     { TOKEN(KWvar); return VAR_TER;}
"while"   { TOKEN(KWwhile); return WHILE_TER;}

    /* Identifier */
[a-zA-Z][a-zA-Z0-9]* { TOKEN_STRING(id, yytext); return ID_TER;}

    /* Integer (decimal/octal) */
{integer} { TOKEN_STRING(integer, yytext); return CONSTINT_TER;}
0[0-7]+   { TOKEN_STRING(oct_integer, yytext); return CONSTINT_TER;}

    /* Floating-Point */
{float} { TOKEN_STRING(float, yytext); return CONSTNOTINT_TER;}

    /* Scientific Notation [Ee][+-]?[0-9]+ */
({integer}|{float})[Ee][+-]?({integer}) { TOKEN_STRING(scientific, yytext); return CONSTNOTINT_TER;}

    /* String */
\"([^"\n]|\"\")*\" {
    char *yyt_ptr = yytext;
    char *str_ptr = string_literal;

    /* Condition guard of the end of string literal
       Check only when *yyt_ptr == '"' */
    while (*(yyt_ptr + 1) != '\0') {
        ++yyt_ptr;

        /* Handle the situation of double quotes */
        if (*yyt_ptr == '"' && *(yyt_ptr + 1) != '\0')
            *str_ptr++ = *yyt_ptr++;

        while (*yyt_ptr != '"')
            *str_ptr++ = *yyt_ptr++;
    }
    *str_ptr = '\0';
    TOKEN_STRING(string, string_literal);
    return STRING_TER;
}
    /* Whitespace */
[ \t]+ { LIST; }

    /* Pseudocomment */
"//&"[ST][+-].* {
    LIST;
    char option = yytext[3];
    switch (option) {
    case 'S':
        opt_src = (yytext[4] == '+') ? 1 : 0;
        break;
    case 'T':
        opt_tok = (yytext[4] == '+') ? 1 : 0;
        break;
    }
}

    /* C++ Style Comment */
"//".* { LIST; }

    /* C Style Comment */
"/*"           { LIST; BEGIN(CCOMMENT); }
<CCOMMENT>"*/" { LIST; BEGIN(INITIAL); }
<CCOMMENT>.    { LIST; }

    /* Newline */
<INITIAL,CCOMMENT>\n {
    if (opt_src) {
        printf("%d: %s\n", line_num, buffer);
    }
    ++line_num;
    buffer[0] = '\0';
    buffer_ptr = buffer;
}

    /* Catch the character which is not accepted by rules above */
. {
    printf("Error at line %d: bad character \"%s\"\n", line_num, yytext);
    exit(-1);
}

%%

static void strCat(const char *Text) {
    while (*Text) {
        *buffer_ptr++ = *Text++;
    }
    *buffer_ptr = '\0';
}

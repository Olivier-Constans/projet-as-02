%{
#include <stdio.h>
#include <string.h>
#include "analyse.tab.h"
#include "expr.h"
%}

%%
"if"           {return IF;}
"else"         {return ELSE;}
"then"         {return THEN;}
"->"           {return FLECHE;}
"let"|"LET"    {return LET;}
"in"|"IN"      {return IN;}
"where"|"WHERE" {return WHERE;}
"fun"          {return T_FUN;}

\/\/.*          {ECHO;printf("\n");}

[()]      {return yytext[0];}

"+"              {return T_PLUS;}
"-"              {return T_MINUS;}
"*"              {return T_MULT;}
"/"              {return T_DIV;}

"<="             {return T_LEQ;}
"<"              {return T_LE;}
">="             {return T_GEQ;}
">"              {return T_GE;}
"=="             {return T_EQ;}
"!="             {return T_NEQ;}

"||"|"or"|"OR"            {return T_OR;}
"&&"|"and"|"AND"             {return T_AND;}
"!"              {return T_NOT;}

"="              {return T_AF;}

";"              {return FIN_EXPR;}

[[:digit:]]+   {yylval.num=atoi(yytext);return T_NB;}
[[:alpha:]]+   {yylval.id=strdup(yytext);return T_ID;}

[[:space:]]    {}


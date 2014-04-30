%{
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "machine.h"
  // Test github dans dessin
struct env* ENV=NULL;
struct configuration* CONF = NULL;

 void printlist(struct cell c){
   /* rajouter l'affichage des  ID, APP et des FUN */
   struct cell *tmp= &c;
   printf("[ ");
   while(tmp != NULL){
     if(tmp->left == NULL){
       printf("NIL "); 
     }
     else{
       if(tmp->left->type == NUM)
	 printf("%d ",tmp->left->expr->num);
       if(tmp->left->type == CELL)
	 printlist(tmp->left->expr->cell);
       if(tmp->left->type == NIL){
	 printf("NIL ");
	 break;
       }
     }
     if(tmp->right == NULL)
       break;
     tmp = &tmp->right->expr->cell;
    
   }
   printf("] "); 
 }
%}

%token <num>T_NB
%token <id> T_ID
%token FIN_EXPR

%token <id>IF
%token <id>ELSE
%token <id>THEN

%token <id>FLECHE

%token LET
%token T_AF
%token T_FUN

%token T_PLUS
%token T_MINUS
%token T_DIV
%token T_MULT

%token T_LEQ
%token T_LE
%token T_GE
%token T_GEQ
%token T_EQ
%token T_NEQ

%token T_OR
%token T_AND
%token T_NOT

%token WHERE
%token IN

%token T_PUSH
%token T_TOP
%token T_NEXT

%token T_CRO
%token T_CRO2

%type <e>s
%type <e>expr

%type <e>paradeffun
%type <e>paraappfun
%type <e>conslist
%type <e>liste

%right FLECHE  ELSE
%right T_EQ
%right T_OR T_AND T_NOT
%right T_LEQ T_GEQ T_LE T_GE T_NEQ 
%right T_AF

%right LET IN WHERE T_ID T_NB
%right FIN_EXPR


%left T_PLUS T_MINUS
%left T_MULT T_DIV
%nonassoc T_M
%left T_APP

%union{
  char* id;
  int num;
  struct expr* e;
 }

%%
lign:    
/*empty*/
| lign s[exp]  FIN_EXPR       {CONF=mk_conf(mk_closure($exp,ENV)); 						//On ajoute à la configuration l'environnement courant qui contient l'expression
                                  step(CONF); 												//traite l'information stocker dans la configuration
                                  if(CONF->closure->expr->type == NUM){
				    printf(">>>>>%d \n",CONF->closure->expr->expr->num);}
                                  if(CONF->closure->expr->type == CELL || CONF->closure->expr->type == NIL){
				    struct cell c = CONF->closure->expr->expr->cell;
				     printf(">>>>>");printlist(c);printf("\n");}}					//permet de traiter les expressions

| lign LET T_ID[id] T_AF s[exp1] FIN_EXPR    {ENV = push_rec_env($id,$exp1,ENV);
                                                CONF=mk_conf(mk_closure($exp1,ENV)); 
                                                step(CONF); 
                                                if(CONF->closure->expr->type == NUM){
				                  printf(">>>>>%d \n",CONF->closure->expr->expr->num);
						}
						if(CONF->closure->expr->type == CELL || CONF->closure->expr->type == NIL){
				                 struct cell c = CONF->closure->expr->expr->cell;
						 printf(">>>>>"); printlist(c);printf("\n");}}	//permet de traiter l'affectation des expression
| lign FIN_EXPR																				//permet de traiter le cas sans expression
;

s:
expr {$$ = $1;}
|liste {$$ = $1;}
|s T_PUSH T_ID  {$$=mk_app(mk_app(mk_op(PUSH),$1),mk_id($3));}	
|s T_PUSH liste {$$=mk_app(mk_app(mk_op(PUSH),$1),$3);}	
|T_TOP liste    {$$=mk_app(mk_op(TOP),$2);}	
|T_TOP T_ID     {$$=mk_app(mk_op(TOP),mk_id($2));}	
|T_NEXT liste   {$$=mk_app(mk_op(NEXT),$2);}	
|T_NEXT T_ID    {$$=mk_app(mk_op(NEXT),mk_id($2));}
;

expr:
// Nombre ou identifiant
T_NB                      {$$=mk_int($1);}													
| T_ID                    {$$=mk_id($1);}
//Opêration arithmetique
| expr T_PLUS expr      {$$=mk_app(mk_app(mk_op(PLUS),$1),$3);}								
| expr T_MINUS expr     {$$=mk_app(mk_app(mk_op(MINUS),$1),$3);}
| expr T_DIV expr       {$$=mk_app(mk_app(mk_op(DIV),$1),$3);}
| expr T_MULT expr      {$$=mk_app(mk_app(mk_op(MULT),$1),$3);}

//traitement des nombres négatif |  T_MINUS expr[expr1] %prec T_M {$$=mk_app(mk_app(mk_op(MINUS),mk_int(0)),$expr1);}
| '(' T_MINUS expr[expr1] ')' %prec T_M {$$=mk_app(mk_app(mk_op(MINUS),mk_int(0)),$expr1);}					


//Operation logique
| expr T_LEQ expr       {$$=mk_app(mk_app(mk_op(LEQ),$1),$3);}
| expr T_LE  expr       {$$=mk_app(mk_app(mk_op(LE),$1),$3);}
| expr T_GEQ expr       {$$=mk_app(mk_app(mk_op(GEQ),$1),$3);}
| expr T_GE expr        {$$=mk_app(mk_app(mk_op(GE),$1),$3);}
| expr T_EQ expr        {$$=mk_app(mk_app(mk_op(EQ),$1),$3);}
| expr T_NEQ expr       {$$=mk_app(mk_op(NOT),mk_app(mk_app(mk_op(EQ),$1),$3));}

| expr T_OR expr        {$$=mk_app(mk_app(mk_op(OR),$1),$3);}
| expr T_AND expr       {$$=mk_app(mk_app(mk_op(AND),$1),$3);}
| T_NOT expr            {$$=mk_app(mk_op(NOT),$2);}

//definition de fonction
| T_FUN paradeffun[para]  {$$=$para;}

// declaration conditionnel
| IF expr[cond] THEN expr[then_br] ELSE expr[else_br]  {$$=mk_cond($cond,$then_br,$else_br);}

// where (optionel)
| expr[fun2] WHERE T_ID[id2] T_AF expr[para2] {$$=mk_app(mk_fun($id2,$fun2),$para2);}
// let in (optionel)
| LET T_ID[id1] T_AF expr[expr1] IN expr[expr2]  {$$=mk_app(mk_fun($id1,$expr2),$expr1);}

// application de fonction
|'(' paraappfun ')'     {$$=$2;}

// expression entre paranthese
| '(' expr ')'          {$$=$2;}
;

//gestion des parametre multiple lors d'une declaration de fonction
paradeffun:
T_ID[id1] paradeffun[para]       {$$=mk_fun($id1,$para);}
| T_ID[idn] FLECHE expr[body1]   {$$=mk_fun($idn,$body1);}
;

//gestion des parametre multiple lors d'un appel de fonction
paraappfun:
paraappfun[expr1] expr[expr2] %prec T_APP     {$$=mk_app($expr1,$expr2);}
| expr  expr[expr1]            {$$=mk_app($1,$expr1);}
;

//syntaxe accepté pour créer une liste
liste:
T_CRO conslist[list] T_CRO2  {$$ = $list;}
|T_CRO T_CRO2 {$$ = mk_cell(NULL,NULL);}
;

conslist:
expr[exp1]','conslist[list] {$$ = mk_cell($exp1,$list);}
|liste[exp1]','conslist[list] {$$ = mk_cell($exp1,$list);}
| expr    {$$ = mk_cell($1,NULL);} 
| liste  {$$ = mk_cell($1,NULL);} 
;
%%

int main(int argc, char *argv[])
{
    yyparse();
    return EXIT_SUCCESS;
}

%{
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "machine.h"

void printPath(struct cell c);
void printlist(struct cell c);
void printPoint(struct cell c);
void printCircle(struct cell c);
void printBezier(struct bezier b);

struct env* ENV=NULL;
struct configuration* CONF = NULL;
int inttmp1=0;
int inttmp2=0;
 void printResult(void){
   printf(">>>>>");
   if(CONF->closure->expr->type == NUM){
     printf("%d",CONF->closure->expr->expr->num);}
   if(CONF->closure->expr->type == CELL || CONF->closure->expr->type == NIL){
     struct cell c = CONF->closure->expr->expr->cell;
     printlist(c);
   }		
   if(CONF->closure->expr->type == POINT){
     printPoint(CONF->closure->expr->expr->cell);
     }
   if(CONF->closure->expr->type == PATH){
     printPath(CONF->closure->expr->expr->cell);
     }
   if(CONF->closure->expr->type == CIRCLE){
     printCircle(CONF->closure->expr->expr->cell);
   }
   if(CONF->closure->expr->type == BEZIER){
     printBezier(CONF->closure->expr->expr->bezier);
   }
   printf("\n");
 }
 void printBezier(struct bezier b){
   printf("Bezier: ");
   printPoint(b.p1->expr->cell);
   printf(", ");
   printPoint(b.p2->expr->cell);
   printf(", ");
   printPoint(b.p3->expr->cell);
   printf(", ");
   printPoint(b.p4->expr->cell);
 }

 void printCircle(struct cell c){
   printf("Cercle: centre= ");
   printPoint(c.left->expr->cell);
   printf(" ,rayon= %d ",c.right->expr->num );
 }

 void printlist(struct cell c){
   struct cell *tmp= &c;
   printf("[ ");
   while(tmp != NULL){
     if(tmp->left == NULL){
       printf("NIL "); 
     }
     else{
       if(tmp->left->type == APP ||tmp->left->type == ID){
	 struct configuration* conf =mk_conf(mk_closure(tmp->left,ENV)); 			
         step(conf); 										
	 if(conf->closure->expr->type == NUM){
	   printf("%d ",conf->closure->expr->expr->num);}
	 if(conf->closure->expr->type == FUN){
	   printf("FUN ");} 
	 if(conf->closure->expr->type == CELL || conf->closure->expr->type == NIL){
	   struct cell c = conf->closure->expr->expr->cell;
	   printlist(c);
	 }
       }
       if(tmp->left->type == FUN ){
	 printf("FUN ");
       }
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

 void printPoint(struct cell c){
    printf("{%d,%d}", c.left->expr->num,c.right->expr->num);
 }
 
 void printPath(struct cell c){
   struct cell *tmp= &c;
   while(tmp != NULL){
     if(tmp->left->type != POINT && tmp->left->type != ID){
       exit(EXIT_FAILURE);
     }
     if(tmp->left->type==ID){
       struct configuration* conf =mk_conf(mk_closure(tmp->left,ENV)); 			
       step(conf); 
       if(conf->closure->expr->type != POINT){
	 exit(EXIT_FAILURE);
       }
       printPoint(conf->closure->expr->expr->cell);
     }else{
       printPoint(tmp->left->expr->cell);
     }
     if(tmp->right == NULL)
       break;
     printf("--");
     tmp = &tmp->right->expr->cell;
     
   }
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

%token T_ACO
%token T_ACO2

%token T_CERCLE
%token T_BEZIER

%type <e>s
%type <e>expr

%type <e>paradeffun
%type <e>paraappfun
%type <e>conslist
%type <e>liste
%type <e>point
%type <e>path
%type <e>circle
%type <e>bezier
%type <e>dessin

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
| lign s[exp]  FIN_EXPR       {CONF=mk_conf(mk_closure($exp,ENV)); 
                               step(CONF);
                               printResult();}

| lign LET T_ID[id] T_AF s[exp1] FIN_EXPR    {ENV = push_rec_env($id,$exp1,ENV);
                                              CONF=mk_conf(mk_closure($exp1,ENV)); 
                                              step(CONF); 
					      printResult();}

| lign FIN_EXPR				      //permet de traiter le cas sans expression
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
|dessin         {$$ = $1;}
;

dessin:
point           {$$ = $1;}
|path           {$$ = $1;}
|circle         {$$ = $1;}
|bezier         {$$ = $1;}
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
| liste T_EQ liste        {$$=mk_app(mk_app(mk_op(EQ),$1),$3);}
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

point:
T_ACO expr[x] ',' expr[y] T_ACO2    {CONF=mk_conf(mk_closure($x,ENV)); 					                                  step(CONF);
                                     if(CONF->closure->expr->type != NUM)
				       exit(EXIT_FAILURE);
				     inttmp1=CONF->closure->expr->expr->num;
                                     CONF=mk_conf(mk_closure($y,ENV)); 					                                  step(CONF);
                                     if(CONF->closure->expr->type != NUM)
				       exit(EXIT_FAILURE);
				     inttmp2=CONF->closure->expr->expr->num;
                                     $$= mk_point(mk_int(inttmp1),mk_int(inttmp2));}
;

path:
point[p1] T_MINUS path[tpath]                     {$$= mk_path($p1,$tpath);}
|T_ID[p1] T_MINUS path[tpath]                     {CONF=mk_conf(mk_closure(mk_id($p1),ENV)); 					                                step(CONF);
                                                   if(CONF->closure->expr->type != POINT)
				                     exit(EXIT_FAILURE);
                                                   $$= mk_path(mk_id($p1),$tpath);}

| T_MINUS point[pi] T_MINUS  path[tpath]          {$$= mk_path($pi,$tpath);} 
| T_MINUS T_ID[pi] T_MINUS  path[tpath]           {CONF=mk_conf(mk_closure(mk_id($pi),ENV)); 					                        step(CONF);
                                                   if(CONF->closure->expr->type != POINT)
				                     exit(EXIT_FAILURE);
                                                   $$= mk_path(mk_id($pi),$tpath);}

| T_MINUS point[pn]                               {$$= mk_path($pn,NULL);}
| T_MINUS T_ID[pn]                                {CONF=mk_conf(mk_closure(mk_id($pn),ENV)); 					                        step(CONF);
                                                   if(CONF->closure->expr->type != POINT)
				                     exit(EXIT_FAILURE);
						   $$= mk_path(mk_id($pn),NULL);}
;
circle:
T_CERCLE '(' point[p] ',' expr[vec] ')'           {$$=mk_circle($p,$vec);}
;

bezier:
T_BEZIER '('point[p1] ','point[p2] ','point[p3] ','point[p4] ')' {$$=mk_bezier($p1,$p2,$p3,$p4);}
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

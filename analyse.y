%{
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "machine.h"

struct env* ENV=NULL;
struct configuration* CONF = NULL;


 void printlist(struct cell c);
 void printResult(struct expr *expr);
 void printPoint(struct expr* c);
 void printPath(struct cell c);
 void printCircle(struct cell c);
 void printBezier(struct bezier b);

 void printRESULT(struct expr *expr){
   printf(">>>>>");
   printResult(expr);
   printf("\n");
 }

 void printResult(struct expr *expr){
   if(expr->type==CELL || expr->type==NIL){
     printlist(expr->expr->cell);
   }else{
   CONF=mk_conf(mk_closure(expr,ENV)); 
   step(CONF);
   if(CONF->closure->expr->type == NUM){
     printf("%d",CONF->closure->expr->expr->num);}  
   if(CONF->closure->expr->type == FUN){
     printf("FUN");
   }
   if(CONF->closure->expr->type == POINT){
     printPoint(CONF->closure->expr);
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
   }
 }

 void printlist(struct cell c){
   struct cell *tmp= &c;
   printf("[ ");
   while(tmp != NULL){
     if(tmp->left == NULL){
       printf("NIL ]");
       return;
     }
     else{
       printResult(tmp->left);
     }
     if(tmp->right == NULL)
       break;
     printf(",");
     tmp = &tmp->right->expr->cell;
   }
   printf("] "); 
 }
void printPoint(struct expr* c){
   if(c->type ==ID){
     struct configuration* conf =mk_conf(mk_closure(c,ENV)); 			
       step(conf); 
       if(conf->closure->expr->type != POINT){
	 exit(EXIT_FAILURE);
       }
       printPoint(conf->closure->expr);
   }else{

   int x;
   int y;
   CONF=mk_conf(mk_closure(c->expr->cell.left,ENV)); 
   step(CONF);
   if(CONF->closure->expr->type != NUM)
     exit(EXIT_FAILURE);
   x=CONF->closure->expr->expr->num;
   CONF=mk_conf(mk_closure(c->expr->cell.right,ENV)); 
   step(CONF);
   if(CONF->closure->expr->type != NUM)
     exit(EXIT_FAILURE);
   y=CONF->closure->expr->expr->num;

  printf("{%d,%d}",x,y);
 }
}

 void printPath(struct cell c){
   struct cell *tmp= &c;
   while(tmp != NULL){
     if(tmp->left->type != POINT && tmp->left->type != ID){
       exit(EXIT_FAILURE);
     }
     printPoint(tmp->left);
     if(tmp->right == NULL)
       break;
     printf("--");
     tmp = &tmp->right->expr->cell;
   }
 }

 void printCircle(struct cell c){
   printf("Cercle: centre= ");
   printPoint(c.left);
   printf(" ,rayon= %d ",c.right->expr->num );
 }

 void printBezier(struct bezier b){
   printf("Bezier: ");
   printPoint(b.p1);
   printf(", ");
   printPoint(b.p2);
   printf(", ");
   printPoint(b.p3);
   printf(", ");
   printPoint(b.p4);
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

%token T_TRANSLATION
%token T_ROTATION
%token T_HOMOTHETIE

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
%type <e>porid

%type <e>translation
%type <e>rotation
%type <e>homothetie

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
| lign s[exp]  FIN_EXPR       {printRESULT($exp) ;}	

| lign LET T_ID[id] T_AF s[exp1] FIN_EXPR    {ENV = push_rec_env($id,$exp1,ENV);
                                              printRESULT($exp1);}	
//permet de traiter le cas sans expression
| lign FIN_EXPR					
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
point       {$$ = $1;}
|path           {$$ = $1;}
|circle         {$$ = $1;}
|bezier         {$$ = $1;}
|translation    {$$ = $1;}
|rotation       {$$ = $1;}
|homothetie     {$$ = $1;}
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

conslist:
expr[exp1]','conslist[list] {$$ = mk_cell($exp1,$list);}
|liste[exp1]','conslist[list] {$$ = mk_cell($exp1,$list);}
| expr    {$$ = mk_cell($1,NULL);} 
| liste  {$$ = mk_cell($1,NULL);} 
;


point:
T_ACO expr[x] ',' expr[y] T_ACO2    {$$= mk_point($x,$y);}
;

path:
point[p1] T_MINUS path[tpath]                     {$$= mk_path($p1,$tpath);}
|T_ID[p1] T_MINUS path[tpath]                     {$$= mk_path(mk_id($p1),$tpath);}

| T_MINUS point[pi] T_MINUS  path[tpath]          {$$= mk_path($pi,$tpath);} 
| T_MINUS T_ID[pi] T_MINUS  path[tpath]           {$$= mk_path(mk_id($pi),$tpath);}

| T_MINUS point[pn]                               {$$= mk_path($pn,NULL);}
| T_MINUS T_ID[pn]                                {$$= mk_path(mk_id($pn),NULL);}
;
circle:
T_CERCLE '(' point[p] ',' expr[vec] ')'           {$$=mk_circle($p,$vec);}
|T_CERCLE '(' T_ID[p] ',' expr[vec] ')'           {$$=mk_circle(mk_id($p),$vec);}
;

translation:
T_TRANSLATION '(' dessin[d] ',' porid[vec] ')'            {$$=mk_app(mk_app(mk_op(TRANS),$d),$vec);}
|T_TRANSLATION '(' T_ID[d] ',' porid[vec] ')'            {$$=mk_app(mk_app(mk_op(TRANS),mk_id($d)),$vec);}

rotation:
T_ROTATION '(' dessin[d] ',' porid[c] ',' expr[ang] ')' {$$=mk_app(mk_app(mk_app(mk_op(ROT),$d),$c),$ang);}
|T_ROTATION '(' T_ID[d] ',' porid[c] ',' expr[ang] ')'  {$$=mk_app(mk_app(mk_app(mk_op(ROT),mk_id($d)),$c),$ang);}
;

homothetie:
T_HOMOTHETIE '(' dessin[d] ',' porid[c] ',' expr[ratio] ')' {$$=mk_app(mk_app(mk_app(mk_op(HOMO),$d),$c),$ratio);}
|T_HOMOTHETIE '(' T_ID[d] ',' porid[c] ',' expr[ratio] ')' {$$=mk_app(mk_app(mk_app(mk_op(HOMO),mk_id($d)),$c),$ratio);}
;

bezier:
T_BEZIER '('porid[p1] ',' porid[p2] ','porid[p3] ','porid[p4] ')' {$$=mk_bezier($p1,$p2,$p3,$p4);}
;

porid:
point          {$$=$1;}
| T_ID         {$$=mk_id($1);}
;

%%

int main(int argc, char *argv[])
{
    yyparse();
    return EXIT_SUCCESS;
}

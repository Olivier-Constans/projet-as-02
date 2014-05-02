
#include <stdlib.h>
#include "expr.h"

struct expr *mk_node(void){
  struct expr *e = malloc(sizeof(struct expr));
  e->expr = malloc(sizeof(union node));
  return e;
}

struct expr *mk_id(char *id){
  struct expr *e = mk_node();
  e->type = ID;

  e->expr->id = id;
  return e;
}

struct expr *mk_fun(char *id, struct expr *body){
  struct expr *e = mk_node();
  e->type = FUN;
  e->expr->fun.id = id;
  e->expr->fun.body = body;
  return e;
}

struct expr *mk_app(struct expr *fun, struct expr *arg){
  struct expr *e = mk_node();
  e->type = APP;
  e->expr->app.fun=fun;
  e->expr->app.arg=arg;
  return e;
}

struct expr *mk_op(enum op op){
  struct expr *e = mk_node();
  e->type=OP;
  e->expr->op = op;
  return e;
}

struct expr *mk_int(int k){
  struct expr *e = mk_node();
  e->type=NUM;
  e->expr->num = k;
  return e;
}

struct expr *mk_cond(struct expr *cond, struct expr *then_br, struct expr *else_br){
  struct expr *e = mk_node();
  e->type = COND;
  e->expr->cond.cond = cond;
  e->expr->cond.then_br = then_br;
  e->expr->cond.else_br = else_br;
  return e;
}
struct expr* mk_structcell(int type ,struct expr * left, struct expr * right){
   struct expr *e = mk_node();
   e->type = type;
   e->expr->cell.left = left;
   e->expr->cell.right = right;
   return e;
}

struct expr* mk_cell(struct expr * left, struct expr * right){
   if(left == NULL && right == NULL){
     return  mk_structcell(NIL,left,right);
   }else{
     return  mk_structcell(CELL,left,right);
   }
}

struct expr* mk_point(struct expr* x, struct expr* y){
  return mk_structcell(POINT,x,y);
}

struct expr* mk_path(struct expr * left, struct expr * right){
  return mk_structcell(PATH ,left,right);
}
struct expr* mk_circle(struct expr * expr_centre, struct expr * expr_rayon){
  return mk_structcell(CIRCLE,expr_centre,expr_rayon);
}

struct expr* mk_bezier(struct expr * p1, struct expr * p2,struct expr * p3, struct expr * p4){
  struct expr *e = mk_node();
  e->type = BEZIER;
  e->expr->bezier.p1= p1;
  e->expr->bezier.p2= p2;
  e->expr->bezier.p3= p3;
  e->expr->bezier.p4= p4;
  return e;
}

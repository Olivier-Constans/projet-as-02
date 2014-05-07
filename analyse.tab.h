/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_ANALYSE_TAB_H_INCLUDED
# define YY_YY_ANALYSE_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    T_NB = 258,
    T_ID = 259,
    FIN_EXPR = 260,
    IF = 261,
    ELSE = 262,
    THEN = 263,
    FLECHE = 264,
    LET = 265,
    T_AF = 266,
    T_FUN = 267,
    T_PLUS = 268,
    T_MINUS = 269,
    T_DIV = 270,
    T_MULT = 271,
    T_LEQ = 272,
    T_LE = 273,
    T_GE = 274,
    T_GEQ = 275,
    T_EQ = 276,
    T_NEQ = 277,
    T_OR = 278,
    T_AND = 279,
    T_NOT = 280,
    WHERE = 281,
    IN = 282,
    T_PUSH = 283,
    T_TOP = 284,
    T_NEXT = 285,
    T_CRO = 286,
    T_CRO2 = 287,
    T_ACO = 288,
    T_ACO2 = 289,
    T_CERCLE = 290,
    T_BEZIER = 291,
    T_TRANSLATION = 292,
    T_ROTATION = 293,
    T_HOMOTHETIE = 294,
    T_M = 295,
    T_APP = 296
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 214 "analyse.y" /* yacc.c:1909  */

  char* id;
  int num;
  struct expr* e;
 

#line 103 "analyse.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_ANALYSE_TAB_H_INCLUDED  */

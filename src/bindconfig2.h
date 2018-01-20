#ifndef YY_parse_h_included
#define YY_parse_h_included
/*#define YY_USE_CLASS 
*/
#line 1 "/usr/share/bison++/bison.h"
/* before anything */
#ifdef c_plusplus
 #ifndef __cplusplus
  #define __cplusplus
 #endif
#endif


 #line 8 "/usr/share/bison++/bison.h"

#line 1512 "bindconfig2.y"
typedef union {
	char* str;
	int lineno;
	int nextquad;
	struct pair2 iiVal;
	struct entry3 *nonT;
} yy_parse_stype;
#define YY_parse_STYPE yy_parse_stype
#ifndef YY_USE_CLASS
#define YYSTYPE yy_parse_stype
#endif

#line 21 "/usr/share/bison++/bison.h"
 /* %{ and %header{ and %union, during decl */
#ifndef YY_parse_COMPATIBILITY
 #ifndef YY_USE_CLASS
  #define  YY_parse_COMPATIBILITY 1
 #else
  #define  YY_parse_COMPATIBILITY 0
 #endif
#endif

#if YY_parse_COMPATIBILITY != 0
/* backward compatibility */
 #ifdef YYLTYPE
  #ifndef YY_parse_LTYPE
   #define YY_parse_LTYPE YYLTYPE
/* WARNING obsolete !!! user defined YYLTYPE not reported into generated header */
/* use %define LTYPE */
  #endif
 #endif
/*#ifdef YYSTYPE*/
  #ifndef YY_parse_STYPE
   #define YY_parse_STYPE YYSTYPE
  /* WARNING obsolete !!! user defined YYSTYPE not reported into generated header */
   /* use %define STYPE */
  #endif
/*#endif*/
 #ifdef YYDEBUG
  #ifndef YY_parse_DEBUG
   #define  YY_parse_DEBUG YYDEBUG
   /* WARNING obsolete !!! user defined YYDEBUG not reported into generated header */
   /* use %define DEBUG */
  #endif
 #endif 
 /* use goto to be compatible */
 #ifndef YY_parse_USE_GOTO
  #define YY_parse_USE_GOTO 1
 #endif
#endif

/* use no goto to be clean in C++ */
#ifndef YY_parse_USE_GOTO
 #define YY_parse_USE_GOTO 0
#endif

#ifndef YY_parse_PURE

 #line 65 "/usr/share/bison++/bison.h"

#line 65 "/usr/share/bison++/bison.h"
/* YY_parse_PURE */
#endif


 #line 68 "/usr/share/bison++/bison.h"

#line 68 "/usr/share/bison++/bison.h"
/* prefix */

#ifndef YY_parse_DEBUG

 #line 71 "/usr/share/bison++/bison.h"
#define YY_parse_DEBUG 1

#line 71 "/usr/share/bison++/bison.h"
/* YY_parse_DEBUG */
#endif

#ifndef YY_parse_LSP_NEEDED

 #line 75 "/usr/share/bison++/bison.h"

#line 75 "/usr/share/bison++/bison.h"
 /* YY_parse_LSP_NEEDED*/
#endif

/* DEFAULT LTYPE*/
#ifdef YY_parse_LSP_NEEDED
 #ifndef YY_parse_LTYPE
  #ifndef BISON_YYLTYPE_ISDECLARED
   #define BISON_YYLTYPE_ISDECLARED
typedef
  struct yyltype
    {
      int timestamp;
      int first_line;
      int first_column;
      int last_line;
      int last_column;
      char *text;
   }
  yyltype;
  #endif

  #define YY_parse_LTYPE yyltype
 #endif
#endif

/* DEFAULT STYPE*/
#ifndef YY_parse_STYPE
 #define YY_parse_STYPE int
#endif

/* DEFAULT MISCELANEOUS */
#ifndef YY_parse_PARSE
 #define YY_parse_PARSE yyparse
#endif

#ifndef YY_parse_LEX
 #define YY_parse_LEX yylex
#endif

#ifndef YY_parse_LVAL
 #define YY_parse_LVAL yylval
#endif

#ifndef YY_parse_LLOC
 #define YY_parse_LLOC yylloc
#endif

#ifndef YY_parse_CHAR
 #define YY_parse_CHAR yychar
#endif

#ifndef YY_parse_NERRS
 #define YY_parse_NERRS yynerrs
#endif

#ifndef YY_parse_DEBUG_FLAG
 #define YY_parse_DEBUG_FLAG yydebug
#endif

#ifndef YY_parse_ERROR
 #define YY_parse_ERROR yyerror
#endif

#ifndef YY_parse_PARSE_PARAM
 #ifndef __STDC__
  #ifndef __cplusplus
   #ifndef YY_USE_CLASS
    #define YY_parse_PARSE_PARAM
    #ifndef YY_parse_PARSE_PARAM_DEF
     #define YY_parse_PARSE_PARAM_DEF
    #endif
   #endif
  #endif
 #endif
 #ifndef YY_parse_PARSE_PARAM
  #define YY_parse_PARSE_PARAM void
 #endif
#endif

/* TOKEN C */
#ifndef YY_USE_CLASS

 #ifndef YY_parse_PURE
  #ifndef yylval
   extern YY_parse_STYPE YY_parse_LVAL;
  #else
   #if yylval != YY_parse_LVAL
    extern YY_parse_STYPE YY_parse_LVAL;
   #else
    #warning "Namespace conflict, disabling some functionality (bison++ only)"
   #endif
  #endif
 #endif


 #line 169 "/usr/share/bison++/bison.h"
#define	IDENTIFIER	258
#define	I_CONSTANT	259
#define	F_CONSTANT	260
#define	STRING_LITERAL	261
#define	PTR_OP	262
#define	INC_OP	263
#define	DEC_OP	264
#define	LEFT_OP	265
#define	RIGHT_OP	266
#define	LE_OP	267
#define	GE_OP	268
#define	EQ_OP	269
#define	NE_OP	270
#define	FUNC_NAME	271
#define	SIZEOF	272
#define	AND_OP	273
#define	OR_OP	274
#define	MUL_ASSIGN	275
#define	DIV_ASSIGN	276
#define	MOD_ASSIGN	277
#define	ADD_ASSIGN	278
#define	SUB_ASSIGN	279
#define	LEFT_ASSIGN	280
#define	RIGHT_ASSIGN	281
#define	AND_ASSIGN	282
#define	XOR_ASSIGN	283
#define	OR_ASSIGN	284
#define	TYPEDEF_NAME	285
#define	ENUMERATION_CONSTANT	286
#define	TYPEDEF	287
#define	EXTERN	288
#define	STATIC	289
#define	AUTO	290
#define	REGISTER	291
#define	INLINE	292
#define	CONST	293
#define	RESTRICT	294
#define	VOLATILE	295
#define	BOOL	296
#define	CHAR	297
#define	SHORT	298
#define	INT	299
#define	LONG	300
#define	SIGNED	301
#define	UNSIGNED	302
#define	FLOAT	303
#define	DOUBLE	304
#define	VOID	305
#define	COMPLEX	306
#define	IMAGINARY	307
#define	STRUCT	308
#define	UNION	309
#define	ENUM	310
#define	ELLIPSIS	311
#define	CASE	312
#define	DEFAULT	313
#define	IF	314
#define	ELSE	315
#define	SWITCH	316
#define	WHILE	317
#define	DO	318
#define	FOR	319
#define	GOTO	320
#define	CONTINUE	321
#define	BREAK	322
#define	RETURN	323
#define	ALIGNAS	324
#define	ALIGNOF	325
#define	ATOMIC	326
#define	GENERIC	327
#define	NORETURN	328
#define	STATIC_ASSERT	329
#define	THREAD_LOCAL	330


#line 169 "/usr/share/bison++/bison.h"
 /* #defines token */
/* after #define tokens, before const tokens S5*/
#else
 #ifndef YY_parse_CLASS
  #define YY_parse_CLASS parse
 #endif

 #ifndef YY_parse_INHERIT
  #define YY_parse_INHERIT
 #endif

 #ifndef YY_parse_MEMBERS
  #define YY_parse_MEMBERS 
 #endif

 #ifndef YY_parse_LEX_BODY
  #define YY_parse_LEX_BODY  
 #endif

 #ifndef YY_parse_ERROR_BODY
  #define YY_parse_ERROR_BODY  
 #endif

 #ifndef YY_parse_CONSTRUCTOR_PARAM
  #define YY_parse_CONSTRUCTOR_PARAM
 #endif
 /* choose between enum and const */
 #ifndef YY_parse_USE_CONST_TOKEN
  #define YY_parse_USE_CONST_TOKEN 0
  /* yes enum is more compatible with flex,  */
  /* so by default we use it */ 
 #endif
 #if YY_parse_USE_CONST_TOKEN != 0
  #ifndef YY_parse_ENUM_TOKEN
   #define YY_parse_ENUM_TOKEN yy_parse_enum_token
  #endif
 #endif

class YY_parse_CLASS YY_parse_INHERIT
{
public: 
 #if YY_parse_USE_CONST_TOKEN != 0
  /* static const int token ... */
  
 #line 212 "/usr/share/bison++/bison.h"
static const int IDENTIFIER;
static const int I_CONSTANT;
static const int F_CONSTANT;
static const int STRING_LITERAL;
static const int PTR_OP;
static const int INC_OP;
static const int DEC_OP;
static const int LEFT_OP;
static const int RIGHT_OP;
static const int LE_OP;
static const int GE_OP;
static const int EQ_OP;
static const int NE_OP;
static const int FUNC_NAME;
static const int SIZEOF;
static const int AND_OP;
static const int OR_OP;
static const int MUL_ASSIGN;
static const int DIV_ASSIGN;
static const int MOD_ASSIGN;
static const int ADD_ASSIGN;
static const int SUB_ASSIGN;
static const int LEFT_ASSIGN;
static const int RIGHT_ASSIGN;
static const int AND_ASSIGN;
static const int XOR_ASSIGN;
static const int OR_ASSIGN;
static const int TYPEDEF_NAME;
static const int ENUMERATION_CONSTANT;
static const int TYPEDEF;
static const int EXTERN;
static const int STATIC;
static const int AUTO;
static const int REGISTER;
static const int INLINE;
static const int CONST;
static const int RESTRICT;
static const int VOLATILE;
static const int BOOL;
static const int CHAR;
static const int SHORT;
static const int INT;
static const int LONG;
static const int SIGNED;
static const int UNSIGNED;
static const int FLOAT;
static const int DOUBLE;
static const int VOID;
static const int COMPLEX;
static const int IMAGINARY;
static const int STRUCT;
static const int UNION;
static const int ENUM;
static const int ELLIPSIS;
static const int CASE;
static const int DEFAULT;
static const int IF;
static const int ELSE;
static const int SWITCH;
static const int WHILE;
static const int DO;
static const int FOR;
static const int GOTO;
static const int CONTINUE;
static const int BREAK;
static const int RETURN;
static const int ALIGNAS;
static const int ALIGNOF;
static const int ATOMIC;
static const int GENERIC;
static const int NORETURN;
static const int STATIC_ASSERT;
static const int THREAD_LOCAL;


#line 212 "/usr/share/bison++/bison.h"
 /* decl const */
 #else
  enum YY_parse_ENUM_TOKEN { YY_parse_NULL_TOKEN=0
  
 #line 215 "/usr/share/bison++/bison.h"
	,IDENTIFIER=258
	,I_CONSTANT=259
	,F_CONSTANT=260
	,STRING_LITERAL=261
	,PTR_OP=262
	,INC_OP=263
	,DEC_OP=264
	,LEFT_OP=265
	,RIGHT_OP=266
	,LE_OP=267
	,GE_OP=268
	,EQ_OP=269
	,NE_OP=270
	,FUNC_NAME=271
	,SIZEOF=272
	,AND_OP=273
	,OR_OP=274
	,MUL_ASSIGN=275
	,DIV_ASSIGN=276
	,MOD_ASSIGN=277
	,ADD_ASSIGN=278
	,SUB_ASSIGN=279
	,LEFT_ASSIGN=280
	,RIGHT_ASSIGN=281
	,AND_ASSIGN=282
	,XOR_ASSIGN=283
	,OR_ASSIGN=284
	,TYPEDEF_NAME=285
	,ENUMERATION_CONSTANT=286
	,TYPEDEF=287
	,EXTERN=288
	,STATIC=289
	,AUTO=290
	,REGISTER=291
	,INLINE=292
	,CONST=293
	,RESTRICT=294
	,VOLATILE=295
	,BOOL=296
	,CHAR=297
	,SHORT=298
	,INT=299
	,LONG=300
	,SIGNED=301
	,UNSIGNED=302
	,FLOAT=303
	,DOUBLE=304
	,VOID=305
	,COMPLEX=306
	,IMAGINARY=307
	,STRUCT=308
	,UNION=309
	,ENUM=310
	,ELLIPSIS=311
	,CASE=312
	,DEFAULT=313
	,IF=314
	,ELSE=315
	,SWITCH=316
	,WHILE=317
	,DO=318
	,FOR=319
	,GOTO=320
	,CONTINUE=321
	,BREAK=322
	,RETURN=323
	,ALIGNAS=324
	,ALIGNOF=325
	,ATOMIC=326
	,GENERIC=327
	,NORETURN=328
	,STATIC_ASSERT=329
	,THREAD_LOCAL=330


#line 215 "/usr/share/bison++/bison.h"
 /* enum token */
     }; /* end of enum declaration */
 #endif
public:
 int YY_parse_PARSE(YY_parse_PARSE_PARAM);
 virtual void YY_parse_ERROR(char *msg) YY_parse_ERROR_BODY;
 #ifdef YY_parse_PURE
  #ifdef YY_parse_LSP_NEEDED
   virtual int  YY_parse_LEX(YY_parse_STYPE *YY_parse_LVAL,YY_parse_LTYPE *YY_parse_LLOC) YY_parse_LEX_BODY;
  #else
   virtual int  YY_parse_LEX(YY_parse_STYPE *YY_parse_LVAL) YY_parse_LEX_BODY;
  #endif
 #else
  virtual int YY_parse_LEX() YY_parse_LEX_BODY;
  YY_parse_STYPE YY_parse_LVAL;
  #ifdef YY_parse_LSP_NEEDED
   YY_parse_LTYPE YY_parse_LLOC;
  #endif
  int YY_parse_NERRS;
  int YY_parse_CHAR;
 #endif
 #if YY_parse_DEBUG != 0
  public:
   int YY_parse_DEBUG_FLAG;	/*  nonzero means print parse trace	*/
 #endif
public:
 YY_parse_CLASS(YY_parse_CONSTRUCTOR_PARAM);
public:
 YY_parse_MEMBERS 
};
/* other declare folow */
#endif


#if YY_parse_COMPATIBILITY != 0
 /* backward compatibility */
 /* Removed due to bison problems
 /#ifndef YYSTYPE
 / #define YYSTYPE YY_parse_STYPE
 /#endif*/

 #ifndef YYLTYPE
  #define YYLTYPE YY_parse_LTYPE
 #endif
 #ifndef YYDEBUG
  #ifdef YY_parse_DEBUG 
   #define YYDEBUG YY_parse_DEBUG
  #endif
 #endif

#endif
/* END */

 #line 267 "/usr/share/bison++/bison.h"
#endif

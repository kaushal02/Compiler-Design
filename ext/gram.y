%expect 2

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct treeNode {
	char* label;
	int count;
	int id;
	struct treeNode** children;
} TREE_NODE;

int id = 0;

TREE_NODE* create_node(char* label, TREE_NODE** child, int count) {
	TREE_NODE* my = (TREE_NODE*)malloc(sizeof(TREE_NODE));
	my->label=(char*)malloc(strlen(label)+1);
	strcpy(my->label, label);
	my->count = count;
	my->id = id++;
	my->children = (TREE_NODE**)malloc(sizeof(TREE_NODE*)*count);
	int i; for(i=0; i<count; i++) (my->children)[i]=child[i];
	return my;
}
int check_print(char* label) {
	if(label == "IDENTIFIER") return 1;
	if(label == "I_CONSTANT") return 1;
	if(label == "F_CONSTANT") return 1;
	if(label == "STRING_LITERAL") return 1;
	return 0;
}
int check_string(char* label) {
	return (label == "STRING_LITERAL");
}
TREE_NODE* create_leaf(char* label2, char* val) {
	TREE_NODE* ex[] = {};
	int sz=strlen(label2);
	if(check_string(label2)) {
		sz += 2;
	}
	if(check_print(label2)) {
		sz += strlen(val)+2;
	}
	char* label=malloc(sz+1);
	strcpy(label, label2);
	if(check_string(label2)) {
		strcat(label, ": \\");
		strcat(label, val);
		label[sz-2] = '\\';
		label[sz-1] = '"';
		// label[sz-1] = '\0';
	}
	else if(check_print(label2)) {
		strcat(label, ": ");
		strcat(label, val);
	}
	return create_node(label, ex, 0);
}

void dfs(TREE_NODE* t) {
	if(t == NULL) return;
	int i, sz=t->count;
	for(i=0; i<sz; i++) {
		printf("\t%d [label=\"%s\"];\n",(t->children[i])->id,(t->children[i])->label);
		printf("\t%d -> %d [arrowhead=open];\n",t->id,(t->children[i])->id);
	}
	for(i=0; i<sz; i++) dfs((t->children[i]));
	if(sz) printf("\t%d [color=gray30, shape=box];\n", t->id);
	else printf("\t%d [color=crimson];\n", t->id);
}
void print_tree(TREE_NODE* t) {
	printf("digraph myC {\n");
	printf("\t%d [label=\"%s\"];\n",t->id,t->label);
	dfs(t);
	printf("}");
}


void yyerror(const char *s) {
	fflush(stdout);
	fprintf(stderr, "*** %s\n", s);
}

int yywrap(void) {
    return 1;
}

int main() {
    yyparse();
    return 0;
}

%}

%union {
	int iVal;
	char* str;
	struct treeNode* tVal;
}

%token <str>	IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL 

%token <str>	PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP FUNC_NAME SIZEOF
%token <str>	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token <str>	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN
%token <str>	TYPEDEF_NAME ENUMERATION_CONSTANT TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token <str>	CONST RESTRICT VOLATILE BOOL CHAR SHORT INT LONG SIGNED UNSIGNED
%token <str>	FLOAT DOUBLE VOID COMPLEX IMAGINARY STRUCT UNION ENUM ELLIPSIS
%token <str>	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%token <str>	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

%type <tVal>	declaration_list function_definition external_declaration translation_unit jump_statement
%type <tVal>	iteration_statement selection_statement expression_statement block_item block_item_list 
%type <tVal>	compound_statement labeled_statement statement static_assert_declaration designator
%type <tVal>	designator_list designation initializer_list initializer direct_abstract_declarator 
%type <tVal>	abstract_declarator type_name identifier_list parameter_declaration parameter_list 
%type <tVal>	parameter_type_list type_qualifier_list pointer direct_declarator declarator alignment_specifier
%type <tVal>	function_specifier type_qualifier atomic_type_specifier enumerator enumerator_list enum_specifier
%type <tVal>	struct_declarator struct_declarator_list specifier_qualifier_list struct_declaration 
%type <tVal>	struct_declaration_list struct_or_union struct_or_union_specifier type_specifier storage_class_specifier
%type <tVal>	init_declarator init_declarator_list declaration_specifiers declaration constant_expression expression
%type <tVal>	assignment_operator assignment_expression conditional_expression logical_or_expression 
%type <tVal>	logical_and_expression inclusive_or_expression exclusive_or_expression and_expression equality_expression
%type <tVal>	relational_expression shift_expression additive_expression multiplicative_expression cast_expression 
%type <tVal>	unary_operator unary_expression argument_expression_list postfix_expression generic_association 
%type <tVal>	generic_assoc_list generic_selection string enumeration_constant constant primary_expression head

%start 			head

%%

head
	: translation_unit {
		TREE_NODE* children[] = {$1};
		$$ = create_node("head", children, 1);
		print_tree($$);
	}

primary_expression
	: IDENTIFIER{
	 	TREE_NODE* children[]={create_leaf("IDENTIFIER", $1)};
	 	$$ = create_node("primary_expression", children, 1);
	}
	| constant {
		TREE_NODE* children[] = {$1};
		$$ = create_node("primary_expression",children,1);
	}
	| string{
		TREE_NODE* children[] = {$1};
		$$ = create_node("primary_expression",children,1);
	}
	| '(' expression ')'{
		TREE_NODE* children[] = {create_leaf("(",""), $2, create_leaf(")","")};
		$$ = create_node("primary_expression",children,3);
	}
	| generic_selection{
		TREE_NODE* children[] = {$1};
		$$ = create_node("primary_expression",children,1);
	}
	;

constant
	: I_CONSTANT		/* includes character_constant */
		{
		 	TREE_NODE* children[]={create_leaf("I_CONSTANT", $1)};
	 		$$ = create_node("constant", children, 1);
		}
	| F_CONSTANT{
			TREE_NODE* children[]={create_leaf("F_CONSTANT", $1)};
	 		$$ = create_node("constant", children, 1);
	}
	| ENUMERATION_CONSTANT{
			TREE_NODE* children[]={create_leaf("ENUMERATION_CONSTANT", $1)};
	 		$$ = create_node("constant", children, 1);
	}	/* after it has been defined as such */
	;

enumeration_constant
	: IDENTIFIER{
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $1)};
	 	$$ = create_node("enumeration_constant", children, 1);
	}
	;

string
	: STRING_LITERAL{
		TREE_NODE* children[] = {create_leaf("STRING_LITERAL", $1)};
	 	$$ = create_node("string", children, 1);
	}
	| FUNC_NAME{
		TREE_NODE* children[] = {create_leaf("FUNC_NAME", $1)};
	 	$$ = create_node("string", children, 1);
	}
	;

generic_selection
	: GENERIC '(' assignment_expression ',' generic_assoc_list ')'{
		TREE_NODE* children[] = {create_leaf("GENERIC",$1), create_leaf("(",""), $3, create_leaf(",",""),$5, create_leaf(")", "")};
		$$ = create_node("generic_selection", children, 6);
	}
	;

generic_assoc_list
	: generic_association{
		TREE_NODE* children[] = {$1};
		$$ = create_node("generic_assoc_list", children, 1);
	}
	| generic_assoc_list ',' generic_association{
		TREE_NODE* children[] = {$1, create_leaf(",",""), $3};
		$$ = create_node("generic_assoc_list", children, 3);
	}
	;

generic_association
	: type_name ':' assignment_expression{
		TREE_NODE* children[] = {$1, create_leaf(":",""), $3};
		$$ = create_node("generic_association", children, 3);
	}
	| DEFAULT ':' assignment_expression{
		TREE_NODE* children[] = {create_leaf("DEFAULT",$1), create_leaf(":",""), $3};
		$$ = create_node("generic_association", children, 3);
	}
	;

postfix_expression
	: primary_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("postfix_expression", children, 1);
	}
	| postfix_expression '[' expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[",""), $3, create_leaf("]","")};
		$$ = create_node("postfix_expression", children, 4);
	}
	| postfix_expression '(' ')' {
		TREE_NODE* children[] = {$1, create_leaf("(",""), create_leaf(")","")};
		$$ = create_node("postfix_expression", children, 3);
	}
	| postfix_expression '(' argument_expression_list ')'{
		TREE_NODE* children[] = {$1,create_leaf("(",""),$3,create_leaf(")","")};
		$$ = create_node("postfix_expression",children,4);
	}
	| postfix_expression '.' IDENTIFIER{
		TREE_NODE* children[] = {$1, create_leaf(".",""), create_leaf("IDENTIFIER",$3)};
		$$ = create_node("postfix_expression", children, 3);
	}
	| postfix_expression PTR_OP IDENTIFIER{
		TREE_NODE* children[] = {$1, create_leaf("PTR_OP",$2), create_leaf("IDENTIFIER",$3)};
		$$ = create_node("postfix_expression", children, 3);
	}
	| postfix_expression INC_OP{
		TREE_NODE* children[] = {$1, create_leaf("INC_OP",$2)};
		$$ = create_node("postfix_expression", children, 2);
	}
	| postfix_expression DEC_OP{
		TREE_NODE* children[] = {$1, create_leaf("DEC_OP",$2)};
		$$ = create_node("postfix_expression", children, 2);
	}
	| '(' type_name ')' '{' initializer_list '}' {
		TREE_NODE* children[] = {create_leaf("(",""), $2, create_leaf(")",""),create_leaf("{",""), $5, create_leaf("}","")};
		$$ = create_node("postfix_expression", children, 6);
	}
	| '(' type_name ')' '{' initializer_list ',' '}'{
		TREE_NODE* children[] = {create_leaf("(",""), $2, create_leaf(")",""), create_leaf("{",""), $5, create_leaf(",",""), create_leaf("}","")};
		$$ = create_node("postfix_expression", children, 7);
	}
	;

argument_expression_list
	: assignment_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("argument_expression_list", children, 1);
	}
	| argument_expression_list ',' assignment_expression{
		TREE_NODE* children[] = {$1, create_leaf(",",""), $3};
		$$ = create_node("argument_expression_list", children, 3);
	}
	;

unary_expression
	: postfix_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("unary_expression", children, 1);
	}
	| INC_OP unary_expression{
		TREE_NODE* children[] = {create_leaf("INC_OP", $1), $2};
	 	$$ = create_node("unary_expression", children, 2);

	}
	| DEC_OP unary_expression{
		TREE_NODE* children[] = {create_leaf("DEC_OP", $1), $2};
	 	$$ = create_node("unary_expression", children, 2);
	}
	| unary_operator cast_expression{
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("unary_expression", children, 2);
	}
	| SIZEOF unary_expression{
		TREE_NODE* children[] = {create_leaf("SIZEOF", $1), $2};
	 	$$ = create_node("unary_expression", children, 2);
	}
	| SIZEOF '(' type_name ')'{
		TREE_NODE* children[] = {create_leaf("SIZEOF", $1), create_leaf("(",""), $3, create_leaf(")","")};
		$$ = create_node("unary_expression", children, 4);
	}
	| ALIGNOF '(' type_name ')'{
		TREE_NODE* children[] = {create_leaf("ALIGNOF", $1), create_leaf("(",""), $3, create_leaf(")","")};
		$$ = create_node("unary_expression", children, 4);
	}
	;

unary_operator
	: '&' {
		TREE_NODE* children[] = {create_leaf("&", "")};
	 	$$ = create_node("unary_operator", children, 1);
	}
	| '*' {
		TREE_NODE* children[] = {create_leaf("*", "")};
	 	$$ = create_node("unary_operator", children, 1);
	}
	| '+' {
		TREE_NODE* children[] = {create_leaf("+", "")};
	 	$$ = create_node("unary_operator", children, 1);
	}
	| '-' {
		TREE_NODE* children[] = {create_leaf("-", "")};
	 	$$ = create_node("unary_operator", children, 1);
	}
	| '~' {
		TREE_NODE* children[] = {create_leaf("~", "")};
	 	$$ = create_node("unary_operator", children, 1);
	}
	| '!' {
		TREE_NODE* children[] = {create_leaf("!", "")};
	 	$$ = create_node("unary_operator", children, 1)
	}
	;

cast_expression
	: unary_expression {
		TREE_NODE* children[] = {$1};
		$$ = create_node("cast_expression", children, 1);
	}
	| '(' type_name ')' cast_expression{
		TREE_NODE* children[] = {create_leaf("(",""), $2, create_leaf(")",""), $4};
		$$ = create_node("cast_expression", children, 4);
	}
	;

multiplicative_expression
	: cast_expression {
		TREE_NODE* children[] = {$1};
		$$ = create_node("multiplicative_expression", children, 1);
	}
	| multiplicative_expression '*' cast_expression {
		TREE_NODE* children[] = {$1, create_leaf("*",""), $3};
		$$ = create_node("multiplicative_expression", children, 3);
	}
	| multiplicative_expression '/' cast_expression {
		TREE_NODE* children[] = {$1, create_leaf("/",""), $3};
		$$ = create_node("multiplicative_expression", children, 3);
	}
	| multiplicative_expression '%' cast_expression{
		TREE_NODE* children[] = {$1, create_leaf("%",""), $3};
		$$ = create_node("multiplicative_expression", children, 3);
	}
	;

additive_expression
	: multiplicative_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("additive_expression", children, 1);
	}
	| additive_expression '+' multiplicative_expression{
		TREE_NODE* children[] = {$1, create_leaf("+",""), $3};
		$$ = create_node("additive_expression", children, 3);
	}
	| additive_expression '-' multiplicative_expression{
		TREE_NODE* children[] = {$1, create_leaf("-",""), $3};
		$$ = create_node("additive_expression", children, 3);
	}
	;

shift_expression
	: additive_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("shift_expression", children, 1);
	}
	| shift_expression LEFT_OP additive_expression{
		TREE_NODE* children[] = {$1, create_leaf("LEFT_OP",$2), $3};
		$$ = create_node("shift_expression", children, 3);
	}
	| shift_expression RIGHT_OP additive_expression{
		TREE_NODE* children[] = {$1, create_leaf("RIGHT_OP",$2), $3};
		$$ = create_node("shift_expression", children, 3);
	}
	;

relational_expression
	: shift_expression {
		TREE_NODE* children[] = {$1};
		$$ = create_node("relational_expression", children, 1);
	}
	| relational_expression '<' shift_expression{
		TREE_NODE* children[] = {$1, create_leaf("<",""), $3};
		$$ = create_node("relational_expression", children, 3);	
	}
	| relational_expression '>' shift_expression{
		TREE_NODE* children[] = {$1, create_leaf(">",""), $3};
		$$ = create_node("relational_expression", children, 3);	
	}
	| relational_expression LE_OP shift_expression{
		TREE_NODE* children[] = {$1, create_leaf("LE_OP",$2), $3};
		$$ = create_node("relational_expression", children, 3);	
	}
	| relational_expression GE_OP shift_expression{
		TREE_NODE* children[] = {$1, create_leaf("GE_OP",$2), $3};
		$$ = create_node("relational_expression", children, 3);	
	}
	;

equality_expression
	: relational_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("equality_expression", children, 1);
	}
	| equality_expression EQ_OP relational_expression{
		TREE_NODE* children[] = {$1, create_leaf("EQ_OP",$2), $3};
		$$ = create_node("equality_expression", children, 3);	
	}
	| equality_expression NE_OP relational_expression{
		TREE_NODE* children[] = {$1, create_leaf("NE_OP",$2), $3};
		$$ = create_node("equality_expression", children, 3);	
	}
	;

and_expression
	: equality_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("and_expression", children, 1);
	}
	| and_expression '&' equality_expression{
		TREE_NODE* children[] = {$1, create_leaf("&",""), $3};
		$$ = create_node("and_expression", children, 3);
	}
	;

exclusive_or_expression
	: and_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("exclusive_or_expression", children, 1);
	}
	| exclusive_or_expression '^' and_expression {
	TREE_NODE* children[] = {$1, create_leaf("^",""), $3};
		$$ = create_node("exclusive_or_expression", children, 3);
	}
	;

inclusive_or_expression
	: exclusive_or_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("inclusive_or_expression", children, 1);
	}
	| inclusive_or_expression '|' exclusive_or_expression{
		TREE_NODE* children[] = {$1, create_leaf("|",""), $3};
		$$ = create_node("inclusive_or_expression", children, 3);
	}
	;

logical_and_expression
	: inclusive_or_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("logical_and_expression", children, 1);
	}
	| logical_and_expression AND_OP inclusive_or_expression{
		TREE_NODE* children[] = {$1, create_leaf("AND_OP",$2), $3};
		$$ = create_node("logical_and_expression", children, 3);
	}
	;

logical_or_expression
	: logical_and_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("logical_or_expression", children, 1);
	}
	| logical_or_expression OR_OP logical_and_expression{
		TREE_NODE* children[] = {$1, create_leaf("OR_OP",$2), $3};
		$$ = create_node("logical_or_expression", children, 3);
	}
	;

conditional_expression
	: logical_or_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("conditional_expression", children, 1);
	}
	| logical_or_expression '?' expression ':' conditional_expression{
		TREE_NODE* children[] = {$1, create_leaf("?",""), $3, create_leaf(":",""), $5};
		$$ = create_node("conditional_expression", children, 5);
	}
	;

assignment_expression
	: conditional_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("assignment_expression", children, 1);
	}
	| unary_expression assignment_operator assignment_expression{
		TREE_NODE* children[] = {$1, $2, $3};
		$$ = create_node("assignment_expression", children, 3);
	}
	;

assignment_operator
	: '='{
		TREE_NODE* children[] = {create_leaf("=", "")};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| MUL_ASSIGN{
		TREE_NODE* children[] = {create_leaf("MUL_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| DIV_ASSIGN{
		TREE_NODE* children[] = {create_leaf("DIV_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| MOD_ASSIGN{
		TREE_NODE* children[] = {create_leaf("MOD_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| ADD_ASSIGN{
		TREE_NODE* children[] = {create_leaf("ADD_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| SUB_ASSIGN{
		TREE_NODE* children[] = {create_leaf("SUB_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| LEFT_ASSIGN{
		TREE_NODE* children[] = {create_leaf("LEFT_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| RIGHT_ASSIGN{
		TREE_NODE* children[] = {create_leaf("RIGHT_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| AND_ASSIGN{
		TREE_NODE* children[] = {create_leaf("AND_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| XOR_ASSIGN{
		TREE_NODE* children[] = {create_leaf("XOR_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	| OR_ASSIGN{
		TREE_NODE* children[] = {create_leaf("OR_ASSIGN", $1)};
	 	$$ = create_node("assignment_operator", children, 1);
	}
	;

expression
	: assignment_expression{
		TREE_NODE* children[] = {$1};
		$$ = create_node("expression", children, 1);
	}
	| expression ',' assignment_expression{
		TREE_NODE* children[] = {$1, create_leaf(",",""), $3};
		$$ = create_node("expression", children, 3);
	}
	;

constant_expression
	: conditional_expression	/* with constraints */
	{
		TREE_NODE* children[] = {$1};
		$$ = create_node("constant_expression", children, 1);
	}
	;

declaration
	: declaration_specifiers ';'{
		TREE_NODE* children[] = {$1, create_leaf(";","")};
		$$ = create_node("declaration", children, 2);
	}
	| declaration_specifiers init_declarator_list ';'{
		TREE_NODE* children[] = {$1, $2, create_leaf(";","")};
		$$ = create_node("declaration", children, 3);
	}
	| static_assert_declaration{
		TREE_NODE* children[] = {$1};
		$$ = create_node("declaration", children, 1);
	}
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers{
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("declaration_specifiers", children, 2);
	}
	| storage_class_specifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("declaration_specifiers", children, 1);
	}
	| type_specifier declaration_specifiers{
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("declaration_specifiers", children, 2);
	}
	| type_specifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("declaration_specifiers", children, 1);
	}
	| type_qualifier declaration_specifiers{
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("declaration_specifiers", children, 2);
	}
	| type_qualifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("declaration_specifiers", children, 1);
	}
	| function_specifier declaration_specifiers{
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("declaration_specifiers", children, 2);
	}
	| function_specifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("declaration_specifiers", children, 1);
	}
	| alignment_specifier declaration_specifiers{
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("declaration_specifiers", children, 2);
	}
	| alignment_specifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("declaration_specifiers", children, 1);
	}
	;

init_declarator_list
	: init_declarator{
		TREE_NODE* children[] = {$1};
		$$ = create_node("init_declarator_list", children, 1);
	}
	| init_declarator_list ',' init_declarator{
		TREE_NODE* children[] = {$1, create_leaf(",",""), $3};
		$$ = create_node("init_declarator_list", children, 3);
	}
	;

init_declarator
	: declarator '=' initializer{
		TREE_NODE* children[] = {$1, create_leaf("=",""), $3};
		$$ = create_node("init_declarator", children, 3);
	}
	| declarator{
		TREE_NODE* children[] = {$1};
		$$ = create_node("init_declarator", children, 1);
	}
	;

storage_class_specifier
	: TYPEDEF	/* identifiers must be flagged as TYPEDEF_NAME */
	{
		TREE_NODE* children[] = {create_leaf("TYPEDEF", $1)};
		$$ = create_node("storage_class_specifier", children, 1);
	}
	| EXTERN{
		TREE_NODE* children[] = {create_leaf("EXTERN", $1)};
		$$ = create_node("storage_class_specifier", children, 1);
	}
	| STATIC{
		TREE_NODE* children[] = {create_leaf("STATIC", $1)};
		$$ = create_node("storage_class_specifier", children, 1);
	}
	| THREAD_LOCAL{
		TREE_NODE* children[] = {create_leaf("THREAD_LOCAL", $1)};
		$$ = create_node("storage_class_specifier", children, 1);
	}
	| AUTO{
		TREE_NODE* children[] = {create_leaf("AUTO", $1)};
		$$ = create_node("storage_class_specifier", children, 1);
	}
	| REGISTER{
		TREE_NODE* children[] = {create_leaf("REGISTER", $1)};
		$$ = create_node("storage_class_specifier", children, 1);
	}
	;

type_specifier
	: VOID{
		TREE_NODE* children[] = {create_leaf("VOID", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| CHAR{
		TREE_NODE* children[] = {create_leaf("CHAR", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| SHORT{
		TREE_NODE* children[] = {create_leaf("SHORT", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| INT{
		TREE_NODE* children[] = {create_leaf("INT", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| LONG{
		TREE_NODE* children[] = {create_leaf("LONG", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| FLOAT{
		TREE_NODE* children[] = {create_leaf("FLOAT", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| DOUBLE{
		TREE_NODE* children[] = {create_leaf("DOUBLE", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| SIGNED{
		TREE_NODE* children[] = {create_leaf("SIGNED", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| UNSIGNED{
		TREE_NODE* children[] = {create_leaf("UNSIGNED", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| BOOL{
		TREE_NODE* children[] = {create_leaf("BOOL", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| COMPLEX{
		TREE_NODE* children[] = {create_leaf("COMPLEX", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| IMAGINARY	  	/* non-mandated extension */
	{
		TREE_NODE* children[] = {create_leaf("IMAGINARY", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	| atomic_type_specifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("type_specifier", children, 1);
	}
	| struct_or_union_specifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("type_specifier", children, 1);	
	}
	| enum_specifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("type_specifier", children, 1);
	}
	| TYPEDEF_NAME		/* after it has been defined as such */
	{
		TREE_NODE* children[] = {create_leaf("TYPEDEF_NAME", $1)};
		$$ = create_node("type_specifier", children, 1);
	}
	;

struct_or_union_specifier
	: struct_or_union '{' struct_declaration_list '}'{
		TREE_NODE* children[] = {$1, create_leaf("{",""), $3, create_leaf("}","")};
		$$ = create_node("struct_or_union_specifier", children, 4);
	}
	| struct_or_union IDENTIFIER '{' struct_declaration_list '}'{
		TREE_NODE* children[] = {$1, create_leaf("IDENTIFIER",$2), create_leaf("{", ""), $4, create_leaf("}","")};
		$$ = create_node("struct_or_union_specifier", children, 5);
	}
	| struct_or_union IDENTIFIER{
		TREE_NODE* children[] = {$1, create_leaf("IDENTIFIER",$2)};
		$$ = create_node("struct_or_union_specifier", children, 2);
	}
	;

struct_or_union
	: STRUCT{
		TREE_NODE* children[] = {create_leaf("STRUCT", $1)};
	 	$$ = create_node("struct_or_union", children, 1);
	}
	| UNION{
		TREE_NODE* children[] = {create_leaf("UNION", $1)};
	 	$$ = create_node("struct_or_union", children, 1);
	}
	;

struct_declaration_list
	: struct_declaration{
		TREE_NODE* children[] = {$1};
		$$ = create_node("struct_declaration_list", children, 1);
	}
	| struct_declaration_list struct_declaration{
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("struct_declaration_list", children, 2);
	}
	;

struct_declaration
	: specifier_qualifier_list ';'	/* for anonymous struct/union */
	{
		TREE_NODE* children[] = {$1, create_leaf(";", "")};
		$$ = create_node("struct_declaration", children, 2);
	}
	| specifier_qualifier_list struct_declarator_list ';'{
		TREE_NODE* children[] = {$1, $2, create_leaf(";","")};
		$$ = create_node("struct_declaration", children, 3);
	}
	| static_assert_declaration{
		TREE_NODE* children[] = {$1};
		$$ = create_node("struct_declaration", children, 1);
	}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list{
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("specifier_qualifier_list", children, 2);
	}
	| type_specifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("specifier_qualifier_list", children, 1);
	}
	| type_qualifier specifier_qualifier_list{
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("specifier_qualifier_list", children, 2);
	}
	| type_qualifier{
		TREE_NODE* children[] = {$1};
		$$ = create_node("specifier_qualifier_list", children, 1);
	}
	;

struct_declarator_list
	: struct_declarator{
		TREE_NODE* children[] = {$1};
		$$ = create_node("struct_declarator_list", children, 1);
	}
	| struct_declarator_list ',' struct_declarator{
		TREE_NODE* children[] = {$1, create_leaf(",",""), $3};
		$$ = create_node("struct_declarator_list", children, 3);
	}
	;

struct_declarator
	: ':' constant_expression{
		TREE_NODE* children[] = {create_leaf(":",""), $2};
		$$ = create_node("struct_declarator", children, 2);
	}
	| declarator ':' constant_expression{
		TREE_NODE* children[] = {$1, create_leaf(":",""), $3};
		$$ = create_node("struct_declarator", children, 3);
	}
	| declarator{
		TREE_NODE* children[] = {$1};
		$$ = create_node("struct_declarator", children, 1);
	}
	;

/* half */

enum_specifier
	: ENUM '{' enumerator_list '}' {
		TREE_NODE* children[] = {create_leaf("ENUM", $1), create_leaf("{", ""), $3, create_leaf("}", "")};
		$$ = create_node("enum_specifier", children, 4);
	}
	| ENUM '{' enumerator_list ',' '}' {
		TREE_NODE* children[] = {create_leaf("ENUM", $1), create_leaf("{", ""), $3, create_leaf(",", ""), create_leaf("}", "")};
		$$ = create_node("enum_specifier", children, 5);
	}
	| ENUM IDENTIFIER '{' enumerator_list '}' {
		TREE_NODE* children[] = {create_leaf("ENUM", $1), create_leaf("IDENTIFIER", $2), create_leaf("{", ""), $4, create_leaf("}", "")};
		$$ = create_node("enum_specifier", children, 5);
	}
	| ENUM IDENTIFIER '{' enumerator_list ',' '}' {
		TREE_NODE* children[] = {create_leaf("ENUM", $1), create_leaf("IDENTIFIER", $2), create_leaf("{", ""), $4, create_leaf(",", ""), create_leaf("}", "")};
		$$ = create_node("enum_specifier", children, 6);
	}
	| ENUM IDENTIFIER {
		TREE_NODE* children[] = {create_leaf("ENUM", $1), create_leaf("IDENTIFIER", $2)};
		$$ = create_node("enum_specifier", children, 2);
	}
	;

enumerator_list
	: enumerator {
		TREE_NODE* children[] = {$1};
		$$ = create_node("enumerator_list", children, 1);
	}
	| enumerator_list ',' enumerator {
		TREE_NODE* children[] = {$1, create_leaf(",", ""), $3};
		$$ = create_node("enumerator_list", children, 3);
	}
	;

enumerator
	: enumeration_constant '=' constant_expression {
		TREE_NODE* children[] = {$1, create_leaf("=", ""), $3};
		$$ = create_node("enumerator", children, 3);
	}
	| enumeration_constant {
		TREE_NODE* children[] = {$1};
		$$ = create_node("enumerator", children, 1);
	}
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')' {
		TREE_NODE* children[] = {create_leaf("ATOMIC", $1), create_leaf("(", ""), $3, create_leaf(")", "")};
		$$ = create_node("atomic_type_specifier", children, 4);
	}
	;

type_qualifier
	: CONST {
		TREE_NODE* children[] = {create_leaf("CONST", $1)};
		$$ = create_node("type_qualifier", children, 1);
	}
	| RESTRICT {
		TREE_NODE* children[] = {create_leaf("RESTRICT", $1)};
		$$ = create_node("type_qualifier", children, 1);
	}
	| VOLATILE {
		TREE_NODE* children[] = {create_leaf("VOLATILE", $1)};
		$$ = create_node("type_qualifier", children, 1);
	}
	| ATOMIC {
		TREE_NODE* children[] = {create_leaf("ATOMIC", $1)};
		$$ = create_node("type_qualifier", children, 1);
	}
	;

function_specifier
	: INLINE {
		TREE_NODE* children[] = {create_leaf("INLINE", $1)};
		$$ = create_node("function_specifier", children, 1);
	}
	| NORETURN {
		TREE_NODE* children[] = {create_leaf("NORETURN", $1)};
		$$ = create_node("function_specifier", children, 1);
	}
	;

alignment_specifier
	: ALIGNAS '(' type_name ')' {
		TREE_NODE* children[] = {create_leaf("ALIGNAS", $1), create_leaf("(", ""), $3, create_leaf(")", "")};
		$$ = create_node("alignment_specifier", children, 4);
	}
	| ALIGNAS '(' constant_expression ')' {
		TREE_NODE* children[] = {create_leaf("ALIGNAS", $1), create_leaf("(", ""), $3, create_leaf(")", "")};
		$$ = create_node("alignment_specifier", children, 4);
	}
	;

declarator
	: pointer direct_declarator {
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("declarator", children, 2);
	}
	| direct_declarator {
		TREE_NODE* children[] = {$1};
		$$ = create_node("declarator", children, 1);
	}
	;

direct_declarator
	: IDENTIFIER {
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $1)};
		$$ = create_node("direct_declarator", children, 1);
	}
	| '(' declarator ')' {
		TREE_NODE* children[] = {create_leaf("(", ""), $2, create_leaf(")", "")};
		$$ = create_node("direct_declarator", children, 3);
	}
	| direct_declarator '[' ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), create_leaf("]", "")};
		$$ = create_node("direct_declarator", children, 3);
	}
	| direct_declarator '[' '*' ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), create_leaf("*", ""), create_leaf("]", "")};
		$$ = create_node("direct_declarator", children, 4);
	}
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), create_leaf("STATIC", $3), $4, $5, create_leaf("]", "")};
		$$ = create_node("direct_declarator", children, 6);
	}
	| direct_declarator '[' STATIC assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), create_leaf("STATIC", $3), $4, create_leaf("]", "")};
		$$ = create_node("direct_declarator", children, 5);
	}
	| direct_declarator '[' type_qualifier_list '*' ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), $3, create_leaf("*", ""), create_leaf("]", "")};
		$$ = create_node("direct_declarator", children, 5);
	}
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), $3, create_leaf("STATIC", $4), $5, create_leaf("]", "")};
		$$ = create_node("direct_declarator", children, 6);
	}
	| direct_declarator '[' type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), $3, $4, create_leaf("]", "")};
		$$ = create_node("direct_declarator", children, 5);
	}
	| direct_declarator '[' type_qualifier_list ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), $3, create_leaf("]", "")};
		$$ = create_node("direct_declarator", children, 4);
	}
	| direct_declarator '[' assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), $3, create_leaf("]", "")};
		$$ = create_node("direct_declarator", children, 4);
	}
	| direct_declarator '(' parameter_type_list ')' {
		TREE_NODE* children[] = {$1, create_leaf("(", ""), $3, create_leaf(")", "")};
		$$ = create_node("direct_declarator", children, 4);
	}
	| direct_declarator '(' ')' {
		TREE_NODE* children[] = {$1, create_leaf("(", ""), create_leaf(")", "")};
		$$ = create_node("direct_declarator", children, 3);
	}
	| direct_declarator '(' identifier_list ')' {
		TREE_NODE* children[] = {$1, create_leaf("(", ""), $3, create_leaf(")", "")};
		$$ = create_node("direct_declarator", children, 4);
	}
	;

pointer
	: '*' type_qualifier_list pointer {
		TREE_NODE* children[] = {create_leaf("*", ""), $2, $3};
		$$ = create_node("pointer", children, 3);
	}
	| '*' type_qualifier_list {
		TREE_NODE* children[] = {create_leaf("*", ""), $2};
		$$ = create_node("pointer", children, 2);
	}
	| '*' pointer {
		TREE_NODE* children[] = {create_leaf("*", ""), $2};
		$$ = create_node("pointer", children, 2);
	}
	| '*' {
		TREE_NODE* children[] = {create_leaf("*", "")};
		$$ = create_node("pointer", children, 1);
	}
	;

type_qualifier_list
	: type_qualifier {
		TREE_NODE* children[] = {$1};
		$$ = create_node("type_qualifier_list", children, 1);
	}
	| type_qualifier_list type_qualifier {
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("type_qualifier_list", children, 2);
	}
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS {
		TREE_NODE* children[] = {$1, create_leaf(",", ""), create_leaf("ELLIPSIS", $3)};
		$$ = create_node("parameter_type_list", children, 3);
	}
	| parameter_list {
		TREE_NODE* children[] = {$1};
		$$ = create_node("parameter_type_list", children, 1);
	}
	;

parameter_list
	: parameter_declaration {
		TREE_NODE* children[] = {$1};
		$$ = create_node("parameter_list", children, 1);
	}
	| parameter_list ',' parameter_declaration {
		TREE_NODE* children[] = {$1, create_leaf(",", ""), $3};
		$$ = create_node("parameter_list", children, 3);
	}
	;

parameter_declaration
	: declaration_specifiers declarator {
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("parameter_declaration", children, 2);
	}
	| declaration_specifiers abstract_declarator {
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("parameter_declaration", children, 2);
	}
	| declaration_specifiers {
		TREE_NODE* children[] = {$1};
		$$ = create_node("parameter_declaration", children, 1);
	}
	;

identifier_list
	: IDENTIFIER {
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $1)};
		$$ = create_node("identifier_list", children, 1);
	}
	| identifier_list ',' IDENTIFIER {
		TREE_NODE* children[] = {$1, create_leaf(",", ""), create_leaf("IDENTIFIER", $3)};
		$$ = create_node("identifier_list", children, 3);
	}
	;

type_name
	: specifier_qualifier_list abstract_declarator {
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("type_name", children, 2);
	}
	| specifier_qualifier_list {
		TREE_NODE* children[] = {$1};
		$$ = create_node("type_name", children, 1);
	}
	;

abstract_declarator
	: pointer direct_abstract_declarator {
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("abstract_declarator", children, 2);
	}
	| pointer {
		TREE_NODE* children[] = {$1};
		$$ = create_node("abstract_declarator", children, 1);
	}
	| direct_abstract_declarator {
		TREE_NODE* children[] = {$1};
		$$ = create_node("abstract_declarator", children, 1);
	}
	;

direct_abstract_declarator
	: '(' abstract_declarator ')' {
		TREE_NODE* children[] = {create_leaf("(", ""), $2, create_leaf(")", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 3);
	}
	| '[' ']' {
		TREE_NODE* children[] = {create_leaf("[", ""), create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 2);
	}
	| '[' '*' ']' {
		TREE_NODE* children[] = {create_leaf("[", ""), create_leaf("*", ""), create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 3);
	}
	| '[' STATIC type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {create_leaf("[", ""), create_leaf("STATIC", $2), $3, $4, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 5);
	}
	| '[' STATIC assignment_expression ']' {
		TREE_NODE* children[] = {create_leaf("[", ""), create_leaf("STATIC", $2), $3, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 4);
	}
	| '[' type_qualifier_list STATIC assignment_expression ']' {
		TREE_NODE* children[] = {create_leaf("[", ""), $2, create_leaf("STATIC", $3), $4, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 5);
	}
	| '[' type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {create_leaf("[", ""), $2, $3, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 4);
	}
	| '[' type_qualifier_list ']' {
		TREE_NODE* children[] = {create_leaf("[", ""), $2, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 3);
	}
	| '[' assignment_expression ']' {
		TREE_NODE* children[] = {create_leaf("[", ""), $2, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 3);
	}
	| direct_abstract_declarator '[' ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 3);
	}
	| direct_abstract_declarator '[' '*' ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), create_leaf("*", ""), create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 4);
	}
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), create_leaf("STATIC", $3), $4, $5, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 6);
	}
	| direct_abstract_declarator '[' STATIC assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), create_leaf("STATIC", $3), $4, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 5);
	}
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), $3, $4, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 5);
	}
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), $3, create_leaf("STATIC", $4), $5, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 6);
	}
	| direct_abstract_declarator '[' type_qualifier_list ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), $3, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 4);
	}
	| direct_abstract_declarator '[' assignment_expression ']' {
		TREE_NODE* children[] = {$1, create_leaf("[", ""), $3, create_leaf("]", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 4);
	}
	| '(' ')' {
		TREE_NODE* children[] = {create_leaf("(", ""), create_leaf(")", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 2);
	}
	| '(' parameter_type_list ')' {
		TREE_NODE* children[] = {create_leaf("(", ""), $2, create_leaf(")", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 3);
	}
	| direct_abstract_declarator '(' ')' {
		TREE_NODE* children[] = {$1, create_leaf("(", ""), create_leaf(")", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 3);
	}
	| direct_abstract_declarator '(' parameter_type_list ')' {
		TREE_NODE* children[] = {$1, create_leaf("(", ""), $3, create_leaf(")", "")};
	 	$$ = create_node("direct_abstract_declarator", children, 4);
	}
	;

initializer
	: '{' initializer_list '}'  {
		TREE_NODE* children[] = {create_leaf("{", ""), $2, create_leaf("}", "")};
	 	$$ = create_node("initializer", children, 3);
	}
	| '{' initializer_list ',' '}'  {
		TREE_NODE* children[] = {create_leaf("{", ""), $2, create_leaf(",", ""), create_leaf("}", "")};
	 	$$ = create_node("initializer", children, 4);
	}
	| assignment_expression  {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("initializer", children, 1);
	}
	;

initializer_list
	: designation initializer  {
		TREE_NODE* children[] = {$1, $2};
	 	$$ = create_node("initializer_list", children, 2);
	}
	| initializer  {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("initializer_list", children, 1);
	}
	| initializer_list ',' designation initializer  {
		TREE_NODE* children[] = {$1, create_leaf(",", ""), $3, $4};
	 	$$ = create_node("initializer_list", children, 4);
	}
	| initializer_list ',' initializer  {
		TREE_NODE* children[] = {$1, create_leaf(",", ""), $3};
	 	$$ = create_node("initializer_list", children, 3);
	}
	;

designation
	: designator_list '='  {
		TREE_NODE* children[] = {$1, create_leaf("=", "")};
	 	$$ = create_node("designation", children, 2);
	}
	;

designator_list
	: designator  {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("designator_list", children, 1);
	}
	| designator_list designator  {
		TREE_NODE* children[] = {$1, $2};
	 	$$ = create_node("designator_list", children, 2);
	}
	;

designator
	: '[' constant_expression ']'  {
		TREE_NODE* children[] = {create_leaf("[", ""), $2, create_leaf("]", "")};
	 	$$ = create_node("designator", children, 3);
	}
	| '.' IDENTIFIER  {
		TREE_NODE* children[] = {create_leaf(".", ""), create_leaf("IDENTIFIER", $2)};
	 	$$ = create_node("designator", children, 2);
	}
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'  {
		TREE_NODE* children[] = {create_leaf("STATIC_ASSERT", $1), create_leaf("(", ""), $3, create_leaf(",", ""), 
		create_leaf("STRING_LITERAL", $5), create_leaf(")", ""), create_leaf(";", "")};
	 	$$ = create_node("static_assert_declaration", children, 7);
	}
	;

statement
	: labeled_statement {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("statement", children, 1);
	}
	| compound_statement {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("statement", children, 1);
	}
	| expression_statement {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("statement", children, 1);
	}
	| selection_statement {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("statement", children, 1);
	}
	| iteration_statement {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("statement", children, 1);
	}
	| jump_statement {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("statement", children, 1);
	}
	;

labeled_statement
	: IDENTIFIER ':' statement {
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $1), create_leaf(":", ""), $3};
	 	$$ = create_node("labeled_statement", children, 3);
	}
	| CASE constant_expression ':' statement {
		TREE_NODE* children[] = {create_leaf("CASE", $1), $2, create_leaf(":", ""), $4};
	 	$$ = create_node("labeled_statement", children, 4);
	}
	| DEFAULT ':' statement {
		TREE_NODE* children[] = {create_leaf("DEFAULT", $1), create_leaf(":", ""), $3};
	 	$$ = create_node("labeled_statement", children, 3);
	}
	;

compound_statement
	: '{' '}' {
		TREE_NODE* children[] = {create_leaf("{", ""), create_leaf("}", "")};
	 	$$ = create_node("compound_statement", children, 2);
	}
	| '{'  block_item_list '}' {
		TREE_NODE* children[] = {create_leaf("{", ""), $2, create_leaf("}", "")};
	 	$$ = create_node("compound_statement", children, 3);
	}
	;

block_item_list
	: block_item {
		TREE_NODE* children[] = {$1};
	 	$$ = create_node("block_item_list", children, 1);
	}
	| block_item_list block_item {
		TREE_NODE* children[] = {$1, $2};
	 	$$ = create_node("block_item_list", children, 2);
	}
	;

block_item
	: declaration {
		TREE_NODE* children[] = {$1};
		$$ = create_node("block_item", children, 1);
	}
	| statement {
		TREE_NODE* children[] = {$1};
		$$ = create_node("block_item", children, 1);
	}
	;

expression_statement
	: ';' {
		TREE_NODE* children[] = {create_leaf(";", "")};
		$$ = create_node("expression_statement", children, 1);
	}
	| expression ';' {
		TREE_NODE* children[] = {$1, create_leaf(";", "")};
		$$ = create_node("expression_statement", children, 2);
	}
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement {
		TREE_NODE* children[] = {create_leaf("IF", $1), create_leaf("(", ""), $3, create_leaf(")", ""), $5, create_leaf("ELSE", $6), $7};
		$$ = create_node("selection_statement", children, 7);
	}
	| IF '(' expression ')' statement {
		TREE_NODE* children[] = {create_leaf("IF", $1), create_leaf("(", ""), $3, create_leaf(")", ""), $5};
		$$ = create_node("selection_statement", children, 5);
	}
	| SWITCH '(' expression ')' statement {
		TREE_NODE* children[] = {create_leaf("SWITCH", $1), create_leaf("(", ""), $3, create_leaf(")", ""), $5};
		$$ = create_node("selection_statement", children, 5);
	}
	;

iteration_statement
	: WHILE '(' expression ')' statement {
		TREE_NODE* children[] = {create_leaf("WHILE", $1), create_leaf("(", ""), $3, create_leaf(")", ""), $5};
		$$ = create_node("iteration_statement", children, 5);
	}
	| DO statement WHILE '(' expression ')' ';' {
		TREE_NODE* children[] = {create_leaf("DO", $1), $2, create_leaf("WHILE", $3), create_leaf("(", ""), $5, create_leaf(")", ""), create_leaf(";", "")};
		$$ = create_node("iteration_statement", children, 7);
	}
	| FOR '(' expression_statement expression_statement ')' statement {
		TREE_NODE* children[] = {create_leaf("FOR", $1), create_leaf("(", ""), $3, $4, create_leaf(")", ""), $6};
		$$ = create_node("iteration_statement", children, 6);
	}
	| FOR '(' expression_statement expression_statement expression ')' statement {
		TREE_NODE* children[] = {create_leaf("FOR", $1), create_leaf("(", ""), $3, $4, $5, create_leaf(")", ""), $7};
		$$ = create_node("iteration_statement", children, 7);
	}
	| FOR '(' declaration expression_statement ')' statement {
		TREE_NODE* children[] = {create_leaf("FOR", $1), create_leaf("(", ""), $3, $4, create_leaf(")", ""), $6};
		$$ = create_node("iteration_statement", children, 6);
	}
	| FOR '(' declaration expression_statement expression ')' statement {
		TREE_NODE* children[] = {create_leaf("FOR", $1), create_leaf("(", ""), $3, $4, $5, create_leaf(")", ""), $7};
		$$ = create_node("iteration_statement", children, 7);
	}
	;

jump_statement
	: GOTO IDENTIFIER ';' {
		TREE_NODE* children[] = {create_leaf("GOTO", $1), create_leaf("IDENTIFIER", $2), create_leaf(";", "")};
		$$ = create_node("jump_statement", children, 3);
	}
	| CONTINUE ';' {
		TREE_NODE* children[] = {create_leaf("CONTINUE", $1), create_leaf(";", "")};
		$$ = create_node("jump_statement", children, 2);
	}
	| BREAK ';' {
		TREE_NODE* children[] = {create_leaf("BREAK", $1), create_leaf(";", "")};
		$$ = create_node("jump_statement", children, 2);
	}
	| RETURN ';' {
		TREE_NODE* children[] = {create_leaf("RETURN", $1), create_leaf(";", "")};
		$$ = create_node("jump_statement", children, 2);
	}
	| RETURN expression ';' {
		TREE_NODE* children[] = {create_leaf("RETURN", $1), $2, create_leaf(";", "")};
		$$ = create_node("jump_statement", children, 3);
	}
	;

translation_unit
	: external_declaration {
		TREE_NODE* children[] = {$1};
		$$ = create_node("translation_unit", children, 1);
	}
	| translation_unit external_declaration {
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("translation_unit", children, 2);	
	}
	;

external_declaration
	: function_definition {
		TREE_NODE* children[] = {$1};
		$$ = create_node("external_declaration", children, 1);
	}
	| declaration {
		TREE_NODE* children[] = {$1};
		$$ = create_node("external_declaration", children, 1);
	}
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement {
		TREE_NODE* children[] = {$1, $2, $3, $4};
	 	$$ = create_node("function_definition", children, 4);
	}
	| declaration_specifiers declarator compound_statement {
		TREE_NODE* children[] = {$1, $2, $3};
	 	$$ = create_node("function_definition", children, 3);
	}
	;

declaration_list
	: declaration {
		TREE_NODE* children[] = {$1};
		$$ = create_node("declaration_list", children, 1);
	}
	| declaration_list declaration {
		TREE_NODE* children[] = {$1, $2};
		$$ = create_node("declaration_list", children, 2);
	}
	;

%%

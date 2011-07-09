%{
/*
 * grammar.y
 *
 * Pascal grammar in Yacc format, based originally on BNF given
 * in "Standard Pascal -- User Reference Manual", by Doug Cooper.
 * This in turn is the BNF given by the ANSI and ISO Pascal standards,
 * and so, is PUBLIC DOMAIN. The grammar is for ISO Level 0 Pascal.
 * The grammar has been massaged somewhat to make it LALR, and added
 * the following extensions.
 *
 * constant expressions
 * otherwise statement in a case
 * productions to correctly match else's with if's
 * beginnings of a separate compilation facility
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NYI fprintf(stderr, "NOT YET IMPLEMENTED at %s:%d\n", __FILE__, __LINE__); exit(1)

extern int line_no;
void yyerror() {
	fprintf(stderr, "parse error at line %d\n", line_no);
}
#define OP_PLUS "+"
#define OP_MINUS "-"
#define OP_OR "||"
#define OP_STAR "*"
#define OP_SLASH "/"
#define OP_DIV "/"
#define OP_MOD "%"
#define OP_AND "&&"
#define OP_EQUAL "="
#define OP_NOTEQUAL "!="
#define OP_LT "<"
#define OP_GT ">"
#define OP_LE "<="
#define OP_GE ">="
#define OP_IN "in"
/*
#define OP_PLUS 1
#define OP_MINUS 2
#define OP_OR 3
#define OP_STAR 4
#define OP_SLASH 5
#define OP_DIV 6
#define OP_MOD 7
#define OP_AND 8
#define OP_EQUAL 9
#define OP_NOTEQUAL 10
#define OP_LT 11
#define OP_GT 12
#define OP_LE 13
#define OP_GE 14
#define OP_IN 15
*/
%}

%union {
	void *ptr;
	struct stringmap *sm;
	char *string;
	int op;
/*	struct program *program;
	struct program_heading *program_heading;
	struct block *block;
	struct identifier *identifier;
	struct constant_definition_part *constant_definition_part;
	struct type_definition_part *type_definition_part;
	struct variable_definition_part *variable_definition_part;
	struct procedure_and_function_definition_part *procedure_and_function_definition_part;
	struct statement_part *statement_part;
*/
}

%type <string> file program program_heading identifier_list block dparts module
%type <string> label_declaration_part label_list label constant_definition_part constant_list
%type <string> constant_definition cexpression csimple_expression cterm cfactor
%type <string> cexponentiation cprimary constant sign non_string type_definition_part
%type <string> type_definition_list type_definition type_denoter new_type new_ordinal_type
%type <string> enumerated_type subrange_type new_structured_type structured_type array_type
%type <string> index_list index_type ordinal_type component_type record_type
%type <string> record_section_list record_section variant_part variant_selector variant_list
%type <string> variant case_constant_list case_constant tag_field tag_type set_type base_type
%type <string> file_type new_pointer_type domain_type variable_declaration_part
%type <string> variable_declaration_list variable_declaration
%type <string> procedure_and_function_declaration_part proc_or_func_declaration_list
%type <string> proc_or_func_declaration procedure_declaration procedure_heading directive
%type <string> formal_parameter_list formal_parameter_section_list formal_parameter_section
%type <string> value_parameter_specification variable_parameter_specification
%type <string> procedural_parameter_specification functional_parameter_specification
%type <string> procedure_identification procedure_block function_declaration function_heading
%type <string> result_type function_identification function_block statement_part
%type <string> compound_statement statement_sequence statement open_statement
%type <string> closed_statement non_labeled_closed_statement non_labeled_open_statement
%type <string> repeat_statement open_while_statement closed_while_statement
%type <string> open_for_statement closed_for_statement open_with_statement
%type <string> closed_with_statement open_if_statement closed_if_statement
%type <string> assignment_statement variable_access indexed_variable index_expression_list
%type <string> index_expression field_designator procedure_statement params
%type <string> actual_parameter_list actual_parameter goto_statement case_statement
%type <string> case_index case_list_element_list case_list_element otherwisepart
%type <string> control_variable initial_value direction final_value record_variable_list
%type <string> boolean_expression expression simple_expression term factor exponentiation
%type <string> primary unsigned_constant unsigned_number unsigned_real
%type <string> function_designator set_constructor member_designator_list member_designator
%type <string> identifier semicolon comma 
%type <string> addop mulop relop

%token <string> AND ARRAY ASSIGNMENT CASE CHARACTER_STRING COLON COMMA CONST DIGSEQ
%token <string> DIV DO DOT DOTDOT DOWNTO ELSE END EQUAL EXTERNAL FOR FORWARD FUNCTION
%token <string> GE GOTO GT IDENTIFIER IF IN LABEL LBRAC LE LPAREN LT MINUS MOD NIL NOT
%token <string> NOTEQUAL OF OR OTHERWISE PACKED PBEGIN PFILE PLUS PROCEDURE PROGRAM RBRAC
%token <string> REALNUMBER RECORD REPEAT RPAREN SEMICOLON SET SLASH STAR STARSTAR THEN
%token <string> TO TYPE UNTIL UPARROW VAR WHILE WITH

%%
file : program
	{
		puts($1);
	}
	| module
	;

program : program_heading semicolon block DOT
	{
		char *str = malloc(strlen($1) + strlen($3)+50);
		sprintf(str, "%s%s", $1, $3);
		$$ = str;
	}
	;

program_heading :
	PROGRAM identifier
	{
		char *str = malloc(strlen($2)+50);
		sprintf(str, "/* PROGRAM NAME: %s */\n", $2);
		$$ = str;
	}
	|
	PROGRAM identifier LPAREN identifier_list RPAREN
	;

identifier_list :
	identifier_list comma identifier
	{
		char *str = malloc(strlen($1) + strlen($3) + 5);
		sprintf(str, "%s, %s", $1, $3);
		$$ = str;
	}
	|
	identifier
	;

block : label_declaration_part
	dparts
	procedure_and_function_declaration_part
	statement_part
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+strlen($4)+10);
		sprintf(str, "%s\n%s\n%s\n%s\n", $1, $2, $3, $4);
		$$ = str;
	}
	;

dparts :
	constant_definition_part
	type_definition_part
	variable_declaration_part
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+10);
		sprintf(str, "%s\n%s\n%s\n", $1, $2, $3);
		$$ = str;
	}
	;

module :
	dparts
	procedure_and_function_declaration_part
	{
		NYI;
	}
	;

label_declaration_part :
	LABEL label_list semicolon
	{ $$ = $2; }
	| {$$ = "";}
	;

label_list : label_list comma label
	| label
	;

label : DIGSEQ
	{ NYI; }
	;

constant_definition_part : CONST constant_list
	{ $$ = $2; }
	| {$$ = "";}
	;

constant_list :
	constant_list constant_definition
	{ 
		char *str = malloc(strlen($1)+strlen($2)+5);
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}
	| constant_definition
	;

constant_definition : identifier EQUAL cexpression semicolon
	{
		char *str = malloc(20+strlen($1)+strlen($3));
		sprintf(str, "var %s = %s;\n", $1, $3);
		$$ = str;
	}
	;

/*constant : cexpression ;  /* good stuff! */

cexpression : csimple_expression
	| csimple_expression relop csimple_expression
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+2);
		sprintf(str, "%s%s%s", $1, $2, $3);
		$$ = str;
	}
	;

csimple_expression : cterm
	| csimple_expression addop cterm
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+2);
		sprintf(str, "%s%s%s", $1, $2, $3);
		$$ = str;
	}
	;

cterm : cfactor
	| cterm mulop cfactor
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+2);
		sprintf(str, "%s%s%s", $1, $2, $3);
		$$ = str;
	}
	;

cfactor : sign cfactor
	{
		char *str = malloc(strlen($1) + strlen($2)+2);
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}
	| cexponentiation
	;

cexponentiation : cprimary
	| cprimary STARSTAR cexponentiation
	{
		char *str = malloc(strlen($1)+strlen($3)+20);
		sprintf(str, "Math.pow(%s, %s)", $1, $3);
		$$ = str;
	}
	;

cprimary : identifier
	| LPAREN cexpression RPAREN
	{
		char *str = malloc(strlen($2)+5);
		sprintf(str, "(%s)", $2);
		$$ = str;
	}
	| unsigned_constant
	| NOT cprimary
	{
		char *str = malloc(strlen($2)+5);
		sprintf(str, "!%s", $2);
		$$ = str;
	}
	;

constant : non_string
	| sign non_string
	{
		char *str = malloc(strlen($1) + strlen($2)+2);
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}
	| CHARACTER_STRING
	;

sign : PLUS { $$ = ""; }
	| MINUS { $$ = "-"; }
	;

non_string : DIGSEQ
	| identifier
	| REALNUMBER
	;

type_definition_part : TYPE type_definition_list
	{
		$$ = $2;
	}
	| {$$ = "";}
	;

type_definition_list : type_definition_list type_definition
	{
		char *str = malloc(strlen($1) + strlen($2) + 3);
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}
	| type_definition
	;

type_definition : identifier EQUAL type_denoter semicolon
	{
		char *str = malloc(strlen($1) + strlen($3)+10);
		sprintf(str, "var %s = %s;\n", $1, $3);
		$$ = str;
	}
	;

type_denoter : identifier
	| new_type
	;

new_type : new_ordinal_type
	| new_structured_type
	| new_pointer_type
	;

new_ordinal_type : enumerated_type
	| subrange_type
	;

enumerated_type : LPAREN identifier_list RPAREN
	{
		char *str = malloc(strlen($2) + 5);
		sprintf(str, "(%s)", $2);
		$$ = str;
	}
	;

subrange_type : constant DOTDOT constant
	{
		/* TODO */
	}
	;

new_structured_type : structured_type
	| PACKED structured_type
	{
		$$ = $2;
	}
	;

structured_type : array_type
	| record_type
	| set_type
	| file_type
	;

array_type : ARRAY LBRAC index_list RBRAC OF component_type
	;

index_list : index_list comma index_type
	| index_type
	;

index_type : ordinal_type ;

ordinal_type : new_ordinal_type
	| identifier
	;

component_type : type_denoter ;

record_type : RECORD record_section_list END
	| RECORD record_section_list semicolon variant_part END
	| RECORD variant_part END
	;

record_section_list : record_section_list semicolon record_section
	| record_section
	;

record_section : identifier_list COLON type_denoter
	;

variant_part : CASE variant_selector OF variant_list semicolon
	| CASE variant_selector OF variant_list
	| {$$ = NULL;}
	;

variant_selector : tag_field COLON tag_type
	| tag_type
	;

variant_list : variant_list semicolon variant
	| variant
	;

variant : case_constant_list COLON LPAREN record_section_list RPAREN
	| case_constant_list COLON LPAREN record_section_list semicolon
	 variant_part RPAREN
	| case_constant_list COLON LPAREN variant_part RPAREN
	;

case_constant_list : case_constant_list comma case_constant
	| case_constant
	;

case_constant : constant
	| constant DOTDOT constant
	;

tag_field : identifier ;

tag_type : identifier ;

set_type : SET OF base_type
	;

base_type : ordinal_type ;

file_type : PFILE OF component_type
	;

new_pointer_type : UPARROW domain_type
	;

domain_type : identifier ;

variable_declaration_part : VAR variable_declaration_list semicolon
	{$$ = $2;}
	| {$$ = "";}
	;

variable_declaration_list :
	  variable_declaration_list semicolon variable_declaration
	{
		char *str = malloc(strlen($1)+strlen($3)+4);
		sprintf(str, "%s%s", $1, $3);
		$$ = str;
	}
	| variable_declaration
	;

variable_declaration : identifier_list COLON type_denoter
	{
		char *str = malloc(strlen($1)+strlen($3)+20);
		sprintf(str, "var %s;\n", $1);
		$$ = str;
	}
	;

procedure_and_function_declaration_part :
	 proc_or_func_declaration_list semicolon
	| {$$ = "";}
	;

proc_or_func_declaration_list :
	  proc_or_func_declaration_list semicolon proc_or_func_declaration
	{
		char *str = malloc(strlen($1)+strlen($3)+5);
		sprintf(str, "%s%s", $1, $3);
		$$ = str;
	}
	| proc_or_func_declaration
	;

proc_or_func_declaration : procedure_declaration
	| function_declaration
	;

procedure_declaration : procedure_heading semicolon directive
	{
		$$ = "";
	}
	| procedure_heading semicolon procedure_block
	{
		char *str = malloc(strlen($1) + strlen($3) + 50);
		sprintf(str, "%s {\n%s}\n", $1, $3);
		$$ = str;
	}
	;

procedure_heading : procedure_identification
	{
		char *str = malloc(strlen($1)+50);
		sprintf(str, "function %s()", $1);
		$$ = str;
	}
	| procedure_identification formal_parameter_list
	{
		char *str = malloc(strlen($1)+strlen($2)+50);
		sprintf(str, "function %s%s", $1, $2);
		$$ = str;
	}
	;

directive : FORWARD
	| EXTERNAL
	;

formal_parameter_list : LPAREN formal_parameter_section_list RPAREN
	{
		char *str = malloc(strlen($2) + 5);
		sprintf(str, "(%s)", $2);
		$$ = str;
	}
	;

formal_parameter_section_list : formal_parameter_section_list semicolon formal_parameter_section
	| formal_parameter_section
	;

formal_parameter_section : value_parameter_specification
	| variable_parameter_specification
	| procedural_parameter_specification
	| functional_parameter_specification
	;

value_parameter_specification : identifier_list COLON identifier
	;

variable_parameter_specification : VAR identifier_list COLON identifier
	;

procedural_parameter_specification : procedure_heading ;

functional_parameter_specification : function_heading ;

procedure_identification : PROCEDURE identifier 
	{
		$$ = $2;
	}
	;

procedure_block : block ;

function_declaration : function_heading semicolon directive /* TODO */
	| function_identification semicolon function_block
	{
		char *str = malloc(strlen($1)+strlen($3)+20);
		sprintf(str, "%s {\n%s}\n", $1, $3);
		$$ = str;
	}
	| function_heading semicolon function_block
	{
		char *str = malloc(strlen($1)+strlen($3)+20);
		sprintf(str, "%s {\n%s}\n", $1, $3);
		$$ = str;
	}
	;

function_heading : FUNCTION identifier COLON result_type
	{
		char *str = malloc(strlen($2)+20);
		sprintf(str, "function %s()", $2);
		$$ = str;
	}
	| FUNCTION identifier formal_parameter_list COLON result_type
	{
		char *str = malloc(strlen($2)+strlen($3)+20);
		sprintf(str, "function %s%s", $2, $3);
		$$ = str;
	}
	;

result_type : identifier ;

function_identification : FUNCTION identifier
	{
		char *str = malloc(strlen($2)+20);
		sprintf(str, "function %s()", $2);
		$$ = str;
	}
	;

function_block : block ;

statement_part : compound_statement ;

compound_statement : PBEGIN statement_sequence END 
	{
		$$ = $2;
	}
	;

statement_sequence : statement_sequence semicolon statement
	{
		char *str = malloc(strlen($1) + strlen($3)+10);
		sprintf(str, "%s;\n%s", $1, $3);
		$$ = str;
	}
	| statement
	;

statement : open_statement
	| closed_statement
	;

open_statement : label COLON non_labeled_open_statement
	{ $$ = $3; }
	| non_labeled_open_statement
	;

closed_statement : label COLON non_labeled_closed_statement
	{ $$ = $3; }
	| non_labeled_closed_statement
	;

non_labeled_closed_statement : assignment_statement
	| procedure_statement
	| goto_statement
	| compound_statement
	| case_statement
	| repeat_statement
	| closed_with_statement
	| closed_if_statement
	| closed_while_statement
	| closed_for_statement
	|
	{ $$ = ""; }
	;

non_labeled_open_statement : open_with_statement
	| open_if_statement
	| open_while_statement
	| open_for_statement
	;

repeat_statement : REPEAT statement_sequence UNTIL boolean_expression
	{
		char *str = malloc(strlen($2)+strlen($4)+100);
		sprintf(str, "do {\n%s} while(!(%s));", $2, $4);
		$$ = str;
	}
	;

open_while_statement : WHILE boolean_expression DO open_statement
	{
		char *str = malloc(100+strlen($2)+strlen($4));
		sprintf(str, "while (%s) {\n%s}\n", $2, $4);
		$$ = str;
	}
	;

closed_while_statement : WHILE boolean_expression DO closed_statement
	{
		char *str = malloc(100+strlen($2)+strlen($4));
		sprintf(str, "while (%s) {\n%s}\n", $2, $4);
		$$ = str;
	}
	;

open_for_statement : FOR control_variable ASSIGNMENT initial_value direction
	  final_value DO open_statement
	{
		char *str = malloc(100+strlen($2)+strlen($4)+strlen($6)+strlen($8));
		if (strcmp($5, "DOWNTO")) { // increasing
			sprintf(str, "for (%s=%s; %s<=%s; %s++) {\n%s}",
				$2, $4, $2, $6, $2, $8);
		} else {
			sprintf(str, "for (%s=%s; %s>=%s; %s--) {\n%s}",
				$2, $4, $2, $6, $2, $8);
		}
		$$ = str;
	}
	;

closed_for_statement : FOR control_variable ASSIGNMENT initial_value direction
	  final_value DO closed_statement
	{
		char *str = malloc(100+strlen($2)+strlen($4)+strlen($6)+strlen($8));
		if (strcmp($5, "DOWNTO")) { // increasing
			sprintf(str, "for (%s=%s; %s<=%s; %s++) {\n%s}",
				$2, $4, $2, $6, $2, $8);
		} else {
			sprintf(str, "for (%s=%s; %s>=%s; %s--) {\n%s}",
				$2, $4, $2, $6, $2, $8);
		}
		$$ = str;
	}
;

open_with_statement : WITH record_variable_list DO open_statement /* TODO */
	;

closed_with_statement : WITH record_variable_list DO closed_statement /* TODO */
	;

open_if_statement : IF boolean_expression THEN statement
	{
		char *str = malloc(strlen($2)+strlen($4)+50);
		sprintf(str, "if(%s) {\n%s}", $2, $4);
		$$ = str;
	}
	| IF boolean_expression THEN closed_statement ELSE open_statement
	{
		char *str = malloc(strlen($2)+strlen($4)+strlen($6)+50);
		sprintf(str, "if(%s) {\n%s} else {\n%s}", $2, $4, $6);
		$$ = str;
	}
	;

closed_if_statement : IF boolean_expression THEN closed_statement
	  ELSE closed_statement
	{
		char *str = malloc(strlen($2)+strlen($4)+strlen($6)+50);
		sprintf(str, "if(%s) {\n%s} else {\n%s}", $2, $4, $6);
		$$ = str;
	}
	;

assignment_statement : variable_access ASSIGNMENT expression
	{
		char *str = malloc(strlen($1) + strlen($3)+5);
		sprintf(str, "%s = %s", $1, $3);
		$$ = str;
	}
	;

variable_access : identifier
	| indexed_variable
	| field_designator
	| variable_access UPARROW
	;

indexed_variable : variable_access LBRAC index_expression_list RBRAC
	{
		char *str = malloc(strlen($1)+strlen($3)+5);
		sprintf(str, "%s[%s]", $1, $3);
		$$ = str;
	}
	;

index_expression_list : index_expression_list comma index_expression
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+3);
		sprintf(str, "%s][%s", $1, $3);
		$$ = str;
	}
	| index_expression
	;

index_expression : expression ;

field_designator : variable_access DOT identifier
	{
		char *str = malloc(strlen($1)+strlen($3)+5);
		sprintf(str, "%s.%s", $1, $3);
		$$ = str;
	}
	;

procedure_statement : variable_access params
	{
		char *str = malloc(strlen($1)+strlen($2)+5);
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}
	| variable_access
	;

params : LPAREN actual_parameter_list RPAREN
	{
		char *str = malloc(strlen($2)+3);
		sprintf(str, "(%s)", $2);
		$$ = str;
	}
	;

actual_parameter_list : actual_parameter_list comma actual_parameter
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+3);
		sprintf(str, "%s, %s", $1, $3);
		$$ = str;
	}
	| actual_parameter
	;

/*
	* this forces you to check all this to be sure that only write and
	* writeln use the 2nd and 3rd forms, you really can't do it easily in
	* the grammar, especially since write and writeln aren't reserved
	*/
actual_parameter : expression
	| expression COLON expression /* TODO handle this more gracefully */
	| expression COLON expression COLON expression
	;

goto_statement : GOTO label
	{
		fprintf(stderr, "NO GOTO ALLOWED!\n");
	}
	;

case_statement : CASE case_index OF case_list_element_list END
	{
		char *str = malloc(strlen($2)+strlen($4)+50);
		sprintf(str, "switch(%s) {\n%s}\n", $2, $4);
		$$ = str;
	}
	| CASE case_index OF case_list_element_list SEMICOLON END
	{
		char *str = malloc(strlen($2)+strlen($4)+50);
		sprintf(str, "switch(%s) {\n%s}\n", $2, $4);
		$$ = str;
	}
	| CASE case_index OF case_list_element_list semicolon
	  otherwisepart statement END
	{
		char *str = malloc(strlen($2)+strlen($4)+strlen($7)+50);
		sprintf(str, "switch(%s) {\n%s\ndefault: %s}\n", $2, $4, $7);
		$$ = str;
	}
	| CASE case_index OF case_list_element_list semicolon
	  otherwisepart statement SEMICOLON END
	{
		char *str = malloc(strlen($2)+strlen($4)+strlen($7)+50);
		sprintf(str, "switch(%s) {\n%s\ndefault: %s}\n", $2, $4, $7);
		$$ = str;
	}
	;

case_index : expression ;

case_list_element_list : case_list_element_list semicolon case_list_element
	{
		char *str = malloc(strlen($1) + strlen($3) + 5);
		sprintf(str, "%s%s", $1, $3);
		$$ = str;
	}
	| case_list_element
	;

case_list_element : case_constant_list COLON statement
	{
		char *str = malloc(strlen($1) + strlen($3)+30);
		sprintf(str, "case %s: %s\nbreak;\n", $1, $3);
		$$ = str;
	}
	;

otherwisepart : OTHERWISE
	| OTHERWISE COLON
	;

control_variable : identifier ;

initial_value : expression ;

direction : TO
	{ $$ = "TO"; }
	| DOWNTO
	{ $$ = "DOWNTO"; }
	;

final_value : expression ;

record_variable_list : record_variable_list comma variable_access
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3));
		sprintf(str, "%s%s %s", $1, $2, $3);
		$$ = str;
	}
	| variable_access
	;

boolean_expression : expression ;

expression : simple_expression
	| simple_expression relop simple_expression
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+4);
		sprintf(str, "%s %s %s", $1, $2, $3);
		$$ = str;
	}
	;

simple_expression : term
	| simple_expression addop term
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+4);
		sprintf(str, "%s %s %s", $1, $2, $3);
		$$ = str;
	}
	;

term : factor
	| term mulop factor
	{
		char *str = malloc(strlen($1)+strlen($2)+strlen($3)+4);
		sprintf(str, "%s %s %s", $1, $2, $3);
		$$ = str;
	}
	;

factor : sign factor
	{
		char *str = malloc(5+strlen($2));
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}
	| exponentiation
	;

exponentiation : primary
	| primary STARSTAR exponentiation
	{
		char *str = malloc(strlen($1)+strlen($3)+10);
		sprintf(str, "Math.pow(%s, %s)", $1, $3);
		$$ = str;
	}
	;

primary : variable_access
	| unsigned_constant
	| function_designator
	| set_constructor
	| LPAREN expression RPAREN
	{
		char *str = malloc(strlen($2)+3);
		sprintf(str, "(%s)", $2);
		$$ = str;
	}
	| NOT primary
	{
		char *str = malloc(strlen($2)+3);
		sprintf(str, "!%s", $2);
		$$ = str;
	}
	;

unsigned_constant : unsigned_number
	| CHARACTER_STRING
	| NIL
	;

unsigned_number : unsigned_real ;

unsigned_real : REALNUMBER
	{
		// remove any leading 0s - pascal lacks octal literals
		char *n = $1;
		while (*n == '0' && (*(n+1)) != 0) n++;
		$$ = n;
	}
	;

/* functions with no params will be handled by plain identifier */
function_designator : variable_access params
	{
		char *str = malloc(strlen($1)+strlen($2)+1);
		sprintf(str, "%s%s", $1, $2);
		$$ = str;
	}
	;

set_constructor : LBRAC member_designator_list RBRAC
	{
		char *str = malloc(strlen($2)+5);
		sprintf(str, "[%s]", $2);
		$$ = str;
	}
	| LBRAC RBRAC
	{
		$$ = "[]";
	}
	;

member_designator_list : member_designator_list comma member_designator
	{
		char *str = malloc(strlen($1)+strlen($3)+3);
		sprintf(str, "%s, %s", $1, $3);
		$$ = str;
	}
	| member_designator
	;

member_designator : member_designator DOTDOT expression
	{
		char *str = malloc(strlen($1)+strlen($3)+2);
		sprintf(str, "%s..%s", $1, $3);
		$$ = str;
	}
	| expression
	;

addop: PLUS {$$ = OP_PLUS;}
	| MINUS {$$ = OP_MINUS;}
	| OR {$$ = OP_OR;}
	;

mulop : STAR {$$ = OP_STAR;}
	| SLASH {$$ = OP_SLASH;}
	| DIV {$$ = OP_DIV;}
	| MOD {$$ = OP_MOD;}
	| AND {$$ = OP_AND;}
	;

relop : EQUAL {$$ = OP_EQUAL;}
	| NOTEQUAL {$$ = OP_NOTEQUAL;}
	| LT {$$ = OP_LT;}
	| GT {$$ = OP_GT;}
	| LE {$$ = OP_LE;}
	| GE {$$ = OP_GE;}
	| IN {$$ = OP_IN;}
	;

identifier : IDENTIFIER

semicolon : SEMICOLON { $$ = ";"; }
	;

comma : COMMA { $$ = ","; }
	;


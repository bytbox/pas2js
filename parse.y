%{
#include <stdio.h>
#include <string.h>
 
void yyerror(const char *str) {
        fprintf(stderr,"error: %s\n",str);
}
 
int yywrap() {
        return 1;
} 
  
%}

%token PROGRAM LABEL CONST TYPE VAR FORWARD TBEGIN TEND PROCEDURE FUNCTION
%token PACKED ARRAY OF GOTO WHILE DO REPEAT UNTIL TO DOWNTO FOR WITH
%token IF THEN ELSE CASE NOT NIL OR DIV MOD AND RECORD SET TFILE
%token LETTER
%token STRING SCALE UDS

%%

program:
	program_heading block "."

program_heading:
	PROGRAM
	{

	}

block:
	declaration_part statement_part

declaration_part:
	label_declaration_part_maybe
	constant_definition_part_maybe
	type_definition_part_maybe
	variable_declaration_part_maybe
	procedure_and_function_declaration_part

label_declaration_part_maybe:
	| label_declaration_part
label_declaration_part:
	LABEL label label_declaration_part1 ";"
label_declaration_part1:
	| "," label label_declaration_part1

constant_definition_part_maybe:
	| constant_definition_part
constant_definition_part:
	CONST constant_definition ";"
	constant_definition_part1
constant_definition_part1:
	| constant_definition ";" constant_definition_part1

constant_definition:
	identifier "=" constant

type_definition_part_maybe:
	| type_definition_part
type_definition_part:
	TYPE type_definition ";" type_definition_part1
type_definition_part1:
	| type_definition ";" type_definition_part1

type_definition:
	identifier "=" type

variable_declaration_part_maybe:
	| variable_declaration_part
variable_declaration_part:
	VAR variable_declaration ";" variable_declaration_part1
variable_declaration_part1:
	| variable_declaration ";" variable_declaration_part1

variable_declaration:
	identifier_list ":" type

procedure_and_function_declaration_part:
	| procedure_and_function_declaration_part procedure_declaration ";"
	| procedure_and_function_declaration_part function_declaration ";"

procedure_declaration:
	procedure_heading ";" block |
	procedure_heading ";" directive |

function_declaration:
	function_heading ";" block |
	function_heading ";" directive |

directive:
	FORWARD

statement_part:
	TBEGIN statement_sequence TEND

procedure_heading:
	PROCEDURE identifier formal_parameter_list_maybe

function_heading:
	FUNCTION identifier formal_parameter_list_maybe ":" result_type

result_type: identifier

formal_parameter_list_maybe: | formal_parameter_list
formal_parameter_list:
	"(" formal_parameter_section formal_parameter_list1 ")"
formal_parameter_list1:
	| ";" formal_parameter_section formal_parameter_list1

formal_parameter_section:
	value_parameter_section |
	variable_parameter_section |
	procedure_parameter_section |
	function_parameter_section

value_parameter_section:
	identifier_list ":" parameter_type

variable_parameter_section:
	VAR identifier_list ":" parameter_type

procedure_parameter_section:
	procedure_heading

function_parameter_section:
	function_heading

parameter_type:
	identifier | conformant_array_schema

conformant_array_schema:
	packed_conformant_array_schema |
	unpacked_conformant_array_schema

packed_conformant_array_schema:
	PACKED ARRAY "[" bound_specification "]" OF identifier

unpacked_conformant_array_schema:
	ARRAY "[" bound_specification0 "]" OF identifier
	|
	ARRAY "[" bound_specification0 "]" OF conformant_array_schema

bound_specification0: bound_specification bound_specification1
bound_specification1: | bound_specification1 ";" bound_specification
bound_specification:
	identifier ".." identifier ":" ordinal_type_identifier

ordinal_type_identifier:
	identifier

statement_sequence:
	statement statement_sequence1
statement_sequence1:
	| statement_sequence1 ";" statement

statement:
	statement0 simple_statement
	|
	statement0 structured_statement
statement0:
	| label ":"

simple_statement:
	| assignment_statement | procedure_statement | goto_statement

assignment_statement:
	variable ":=" expression
	|
	identifier ":=" expression

procedure_statement:
	identifier actual_parameter_list_maybe

goto_statement:
	GOTO label

structured_statement:
	compound_statement | repetitive_statement | conditional_statement | with_statement

compound_statement:
	TBEGIN statement_sequence TEND

repetitive_statement:
	while_statement | repeat_statement | for_statement

while_statement:
	WHILE expression DO statement

repeat_statement:
	REPEAT statement_sequence UNTIL expression

for_statement:
	FOR identifier ":=" initial_expression TO final_expression DO statement
	|
	FOR identifier ":=" initial_expression DOWNTO final_expression DO statement 

initial_expression: expression

final_expression: expression

conditional_statement: if_statement | case_statement

if_statement: IF expression THEN statement else_maybe
else_maybe: | ELSE statement

case_statement:
	CASE expression OF
	case_limbs 
	TEND

case_limbs:
	case_limb case_limbs0 case_limbs1
case_limbs0: | ";" case_limb case_limbs0
case_limbs1: | ";"
case_limb: case_label_list ":" statement

case_label_list:
	constant case_label_list0
case_label_list0: | "," constant

with_statement:
	WITH record_variable_list DO statement

actual_parameter_list_maybe: | actual_parameter_list
actual_parameter_list:
	"(" actual_parameter actual_parameter_list0 ")"
actual_parameter_list0:
	|
	"," actual_parameter actual_parameter_list0

actual_parameter:
	actual_value

actual_value: expression

expression:
	simple_expression
	|
	simple_expression relational_operator simple_expression

simple_expression:
	sign0 term simple_expression0
simple_expression0: | addition_operator term simple_expression0
sign0: | sign

term: factor term0
term0: | multiplication_operator factor term0

factor:
	variable
	|
	number
	|
	string
	|
	set
	|
	NIL
	|
	function_call
	|
	"(" expression ")"
	|
	NOT factor

relational_operator:
	"=" | "<>" | "<" | "<=" | ">" | ">=" | "in"

addition_operator:
	"+" | "-" | OR

multiplication_operator:
	"*" | "/" | DIV | MOD | AND

variable:
	identifier | component_variable | referenced_variable

component_variable:
	indexed_variable
	|
	field_designator

indexed_variable:
	array_variable "[" expression_list "]"

field_designator:
	record_variable "." identifier

set: "[" element_list "]"

element_list:
	|
	expression element_list0
element_list0:
	|
	"," expression element_list0

function_call: identifier actual_parameter_list

type: simple_type | structured_type | pointer_type | identifier

simple_type:
	subrange_type
	|
	enumerated_type

enumerated_type:
	"(" identifier_list ")"

subrange_type:
	lower_bound ".." upper_bound

lower_bound: constant

upper_bound: constant

structured_type:
	unpacked_structured_type
	|
	PACKED unpacked_structured_type

unpacked_structured_type:
	array_type | record_type | set_type | file_type

array_type:
	ARRAY "[" index_type array_type0 "]" OF element_type
array_type0:
	| "," index_type array_type0

index_type: simple_type

element_type: type

record_type: RECORD field_list TEND

set_type: SET OF base_type

base_type: type

file_type: TFILE OF file_component_type

file_component_type: type

pointer_type: "^" identifier

field_list:
	|
	fixed_part semi_maybe
	|
	fixed_part ";" variant_part semi_maybe
	|
	variant_part semi_maybe
	
semi_maybe:
	| ";"

fixed_part: record_section fixed_part0
fixed_part0: | ";" record_section fixed_part0

record_section: identifier_list ":" type

variant_part:
	CASE tag_field identifier OF variant variant_part0
variant_part0: | ";" variant variant_part0

tag_field:
	|
	identifier ":"

variant: case_label_list ":" "(" field_list ")"

identifier: letter identifier0
identifier0:
	|
	letter identifier0
	|
	UDS identifier0

referenced_variable: identifier "^"

record_variable_list: record_variable record_variable_list0
record_variable_list0: | "," record_variable record_variable_list0
record_variable: variable

array_variable: variable

/*
variable_list: variable variable_list0
variable_list0: | "," variable variable_list0
*/

identifier_list: identifier identifier_list0
identifier_list0: | "," identifier identifier_list0

expression_list: expression expression_list0
expression_list0: | "," expression expression_list0

number: integer_number | real_number

integer_number: digit_sequence

real_number:
	digit_sequence "."
	|
	digit_sequence "." unsigned_digit_sequence
	|
	digit_sequence "." scale_factor
	|
 	digit_sequence "." unsigned_digit_sequence scale_factor
	|
	digit_sequence scale_factor

scale_factor: SCALE

unsigned_digit_sequence: UDS

digit_sequence:
	sign0 unsigned_digit_sequence

sign:
	"+"
	|
	"-"

letter: LETTER

string: STRING

label: integer_number

constant:
	sign0 identifier
	|
	sign0 number
	|
	string


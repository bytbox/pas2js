%{
#include <stdio.h>

#include "y.tab.h"
%}

%option case-insensitive

%%

program		return PROGRAM;
label		return LABEL;
const		return CONST;
type		return TYPE;
var		return VAR;
forward		return FORWARD;
begin		return TBEGIN;
end		return TEND;
procedure	return PROCEDURE;
function	return FUNCTION;
packed		return PACKED;
array		return ARRAY;
of		return OF;
goto		return GOTO;
while		return WHILE;
do		return DO;
repeat		return REPEAT;
until		return UNTIL;
to		return TO;
downto		return DOWNTO;
for		return FOR;
if		return IF;
then		return THEN;
else		return ELSE;
case		return CASE;
with		return WITH;
not		return NOT;
nil		return NIL;
or		return OR;
div		return DIV;
mod		return MOD;
and		return AND;
record		return RECORD;
set		return SET;
file		return TFILE;
e[0-9]+		return SCALE;
[0-9]+		return UDS;
[A-Za-z]	return LETTER;
'[^']'		return STRING;
[ \t]+		/* whitespace */
\n		/* newline */
.		return yytext[0];

%%


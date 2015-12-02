%{
#include <stdio.h>
#include "parser.tab.h"
  extern int yydebug;
  yydebug = 1;
%}

RELATION S|P|SP|PRDCT|CUST|ORDERS
ATTRIBUTE CNO|CITY|CNAME|SNO|PNO|TQTY|SNAME|QUOTA|PNAME|COST|AVQTY|S#|STATUS|P#|COLOR|WEIGHT|QTY
BINARYOPERATION UNION|INTERSECT|MINUS|TIMES|JOIN|DIVIDEBY
COMPARE <|>|<=|>=|=|<>
LEFT_BRACKET \[
RIGHT_BRACKET \]
%%
[ \t\n]            { /* printf("'%s';", yytext); */ }
WHERE              { /* printf("WHERE;       \n" ) ;*/ return WHERE;         }
[0-9]+             { /* printf("DIGIT        \n" ) ;*/ return DIGIT;         }
RENAME             { /* printf("RENAME;      \n" ) ;*/ return RENAME;        }
,                  { /* printf("COMMA;       \n" ) ;*/ return COMMA;         }
{RELATION}         { /* printf("RELATION;    \n" ) ;*/ return RELATION;      }
{ATTRIBUTE}        { /* printf("ATTRIBUTE;   \n" ) ;*/ return ATTRIBUTE;     }
{BINARYOPERATION}  { /* printf("BINARY_OP;   \n" ) ;*/ return BINARY_OP;     }
{LEFT_BRACKET}     { /* printf("LEFT_BRACKET \n" ) ;*/ return LEFT_BRACKET;  }
{RIGHT_BRACKET}    { /* printf("RIGHT_BRACKET\n" ) ;*/ return RIGHT_BRACKET; }
AS                 { /* printf("AS;          \n" ) ;*/ return AS;            }
{COMPARE}          { /* printf("COMPARE;     \n" ) ;*/ return COMPARE;       }
\(                 { /* printf("LEFT_PAREN");       */ return LEFT_PAREN;    }
\)                 { /* printf("RIGHT_PAREN");      */ return RIGHT_PAREN;   }
.                  { printf("\ninvalid character: '%s'\n", yytext);printf("\nREJECT\n");}
%%


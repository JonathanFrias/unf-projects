%token DIGIT RENAME ATTRIBUTE BINARY_OP AS RELATION COMPARE WHERE COMMA LEFT_PAREN RIGHT_PAREN LEFT_BRACKET RIGHT_BRACKET
%%
start:
  expression { printf("\nACCEPT\n"); }
  ;

expression:
  one_relation_expression
  | two_relation_expression
  ;

one_relation_expression:
  renaming
  | restriction
  | projection
  ;

renaming:
  term RENAME ATTRIBUTE AS ATTRIBUTE
  ;

term:
  RELATION
  | LEFT_PAREN expression RIGHT_PAREN
  ;

restriction:
  term WHERE comparison
  ;

projection:
  term
  | term LEFT_BRACKET attribute_commalist RIGHT_BRACKET
  ;

attribute_commalist:
  ATTRIBUTE
  | ATTRIBUTE COMMA attribute_commalist
  ;

two_relation_expression:
  projection binary_operation expression
  ;

binary_operation:
  BINARY_OP
  ;

comparison:
  ATTRIBUTE COMPARE DIGIT
  ;

%%
yyerror() {
   printf("\nREJECT\n");
   exit(0);
}

main() {
   yyparse();
}

yywrap() {

}


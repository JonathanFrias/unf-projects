p5:
	flex lex.l  && bison -d parser.y && cc -o p5 parser.tab.c lex.yy.c

debug:
	flex lex.l  && bison --debug -v -d parser.y && cc -o p5_debug parser.tab.c lex.yy.c

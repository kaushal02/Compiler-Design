all: parse

lex: scan.1.l gram.1.y lexer.c
	flex scan.1.l
	yacc -d gram.1.y
	gcc -w -c lexer.c
	gcc -w -o ../bin/lexer lex.yy.c lexer.o -lfl
	-rm y.tab.c y.tab.h lex.yy.c lexer.o

parse: bindconfig2.l bindconfig2.y
	lex bindconfig2.l
	yacc --verbose --debug -d bindconfig2.y -o bindconfig2.cc
	cc -c lex.yy.c -o lex.yy.o
	c++ -std=c++11 -w lex.yy.o bindconfig2.cc -o ../bin/parser
	-rm bindconfig2.cc lex.yy.o bindconfig2.hh bindconfig2.output lex.yy.c

clean:
	-rm ../bin/lexer ../bin/parser
	-rm ../out/dump* ../out/parsetree.pdf ../out/code.s

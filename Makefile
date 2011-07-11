CC = cc
LEX = lex
YACC = yacc
YFLAGS = -d -v
CFLAGS = -g

all: pas2js

pas2js: pas2js.o lex.o parse.o

lex.o parse.o: y.tab.h
y.tab.h: parse.c

clean:
	rm -rf *.o pas2js parse.c lex.c y.tab.h y.output


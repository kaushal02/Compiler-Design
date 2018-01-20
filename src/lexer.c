#include "y.tab.c"
#include <stdio.h>
extern int yylex();
extern char *yytext;

int main() {
	int token;
	while((token=yylex()) != 0) {
		if(token == IDENTIFIER) {
			printf("<IDENTIFIER, %d, %s>\n", token, yytext);
		}
	}
	return 0;
}

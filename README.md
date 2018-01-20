				README
				
			CS335 Project Milestone 1
		kaushal agrawal (14313), dhawal upadhyay (14218)

Initial steps:
	cd /src
	make
	cd ..
	bash +x 777 run.sh

compile options:
	./run.sh ./test/test1.c		//build parse tree on file test1.c
	./run.sh -p ./test/test1.c	//same as previous
	./run.sh -p ./test/test1.c -o my.pdf //build parse tree into my.pdf  
	./run.sh -help			//redirects to readme
	./run.sh -l ./test/test1.c	//sample standalone scanner

To clean:
	cd /src
	make clean  //deletes all intermediate files including lexer and parser

Notes:
-gram.1.y and scan.1.l are used to create the lexer
-gram.y and scan.l are used to create the parser
-./run.sh -p builds the parse-tree in file parsetree.pdf
-./run.sh -l outputs scanned tokens (incomplete, only for testing) on terminal
-5 sample files are provided in test directory

Acknowledgement:
-Grammar specification taken from http://www.quut.com/c/ANSI-C-grammar-y.html
-Token specification taken from http://www.quut.com/c/ANSI-C-grammar-l-2011.html
-Lex/YACC tutorials from http://www.iitk.ac.in/LDP/HOWTO/Lex-YACC-HOWTO.html
-Test files taken from internet
-Tutorial videos on youtube

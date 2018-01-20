Compilers Project
=======
Run the following commands to build the project

    cd /src
    make
    cd ..
    bash +x 777 run.sh

Run clean after you're done

    cd /src
    make clean

*clean* deletes all intermediate files including lexer and parser

## compile options

* `./run.sh ./test/test1.c` builds parse tree on file test1.c
* `./run.sh -p ./test/test1.c` same as above
* `./run.sh -p ./test/test1.c -o my.pdf` builds parse tree into my.pdf
* `./run.sh -help` redirects to readme
* `./run.sh -l ./test/test1.c` sample standalone scanner

## Notes

* _gram.1.y_ and _scan.1.l_ are used to create the lexer
* _gram.y_ and _scan.l_ are used to create the parser
* `./run.sh -p` builds the parse-tree in file parsetree.pdf
* `./run.sh -l` outputs scanned tokens (incomplete, only for testing) on terminal
* sample files are provided in test directory

## Acknowledgements

* Grammar specification taken from  [here](http://www.quut.com/c/ANSI-C-grammar-y.html)
* Token specification taken from [here](http://www.quut.com/c/ANSI-C-grammar-l-2011.html)
* Lex/YACC tutorials from [here](http://www.iitk.ac.in/LDP/HOWTO/Lex-YACC-HOWTO.html)
* Test files taken from internet
* Tutorial videos on [YouTube](https://www.youtube.com)

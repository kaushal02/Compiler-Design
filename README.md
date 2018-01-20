Compilers Project
=======

Make the _bash_ file executable

    chmod +x *sh

To build the project, simply do

    ./build.sh

All output files are stored in _out/_ once you compile a testfile

## compile options

It is recommended to build the project before using any compile option

* `./run.sh ./test/test1.c` builds parse tree on file test1.c
* `./run.sh -p ./test/test1.c` same as above
* `./run.sh -p ./test/test1.c -o my.pdf` builds parse tree into my.pdf
* `./run.sh -help` redirects to readme
* `./run.sh -l ./test/test1.c` sample standalone scanner

## Notes

* _gram.1.y_ and _scan.1.l_ are used to create the lexer
* _gram.y_ and _scan.l_ are used to create the parser
* `./run.sh -p` builds the parse-tree in file _parsetree.pdf_
* `./run.sh -l` outputs scanned tokens (incomplete, only for testing) on terminal
* sample files are provided in test directory

## require

    flex
    bison
    graphviz

## Acknowledgements

* Grammar specification taken from  [here](http://www.quut.com/c/ANSI-C-grammar-y.html)
* Token specification taken from [here](http://www.quut.com/c/ANSI-C-grammar-l-2011.html)
* Lex/YACC tutorials from [here](http://www.iitk.ac.in/LDP/HOWTO/Lex-YACC-HOWTO.html)
* Test files taken from internet
* Tutorial videos on [YouTube](https://www.youtube.com)

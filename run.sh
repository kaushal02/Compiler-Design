#!/bin/bash
if [ $# == 0 ]; then
	echo "Please enter some arguments."
elif [ $# == 1 ]; then
	if [ "$1" == "-help" ]; then
		cat README.md
	else
		if [ -f "$1" ]; then
			./bin/parser < "$1" > temp.dot
			dot -Tpdf temp.dot -o out/parsetree.pdf
			# xdg-open out/parsetree.pdf
			rm temp.dot
			subl out/dumpQUAD.out
			cat out/kbug.out
			subl out/code.s
		else
			echo "File does not exist."
		fi
	fi
# elif [ "$1" == -l ]; then
# 	if [ $# == 2 ]; then
# 		if [ -f "$2" ]; then
# 			./bin/lexer < "$2"
# 		else
# 			echo "File does not exist."
# 		fi
# 	else
# 		echo "Invalid command."
# 	fi
# elif [ "$1" == -p ]; then
# 	if [ $# == 2 ]; then
# 		if [ -f "$2" ]; then
# 			./bin/parser < "$2" > temp.dot
# 			dot -Tpdf temp.dot -o parsetree.pdf
# 			xdg-open parsetree.pdf
# 			rm temp.dot
# 		else
# 			echo "File does not exist."
# 		fi
# 	elif [ $# == 4 ]; then
# 		if [ "$2" == -o ]; then
# 			if [ -f "$4" ]; then
# 				./bin/parser < "$4" > temp.dot
# 				dot -Tpdf temp.dot -o "$3"
# 				xdg-open "$3"
# 				rm temp.dot
# 			else
# 				echo "File does not exist."
# 			fi
# 		elif [ "$3" == -o ]; then
# 			if [ -f "$2" ]; then
# 				./bin/parser < "$2" > temp.dot
# 				dot -Tpdf temp.dot -o "$4"
# 				xdg-open "$4"
# 				rm temp.dot
# 			else
# 				echo "File does not exist."
# 			fi
# 		else
# 			echo "Invalid command."
# 		fi
# 	else
# 		echo "Invalid command."
# 	fi
else
	echo "Invalid command."
fi

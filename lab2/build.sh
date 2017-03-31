#!/bin/bash
echo "YACC PROCESS..."
yacc -d copy.y -o copy.tab.c 
echo "lEX PROCESS..."
lex copy.l
echo "COMPILE..."
g++ lex.yy.c copy.tab.c -o parser

echo "Run..."
cat test.file | ./parser

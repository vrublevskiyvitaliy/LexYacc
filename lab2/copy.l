%{
    #include <string>
    #define YYSTYPE std::string
    #include "copy.tab.h"
    void yyerror(char *s);
%}

%option yylineno
%option noyywrap


%x STR

%%
NAME return NAME;
PARENT return PARENT;
BYTES return BYTES;
POINTER return POINTER;
FREQ return FREQ;
RULES return RULES;
EXIT return EXIT;
DSGROUP return DSGROUP;
SSPTR return SSPTR;
COMPRTN return COMPRTN;
SOURCE return SOURCE;
RMNAME return RMNAME;
SEGM return SEGM;

[0-9]+          {
    yylval = yytext;
    return NUM;
}
[a-zA-Z_][a-zA-Z0-9_]* { yylval = yytext;
    return ID;
}
<STR>[^\\\n"]+  yylval += yytext;
<STR>\\n        yylval += '\n';
<STR>\\         yyerror("Invalid escape sequence");
<STR>\n         yyerror("Newline in string literal");
[ \t\r\n]       ; // whitespace
[-{};()<>=+*/!,] { return *yytext; }
.               yyerror("Invalid character");

%%
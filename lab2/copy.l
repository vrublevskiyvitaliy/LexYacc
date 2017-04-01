%{
    #include <string>
    #define YYSTYPE std::string
    #include "copy.tab.h"
    void yyerror(char *s);
    
    char m_invalidEscape[] = "Invalid escape sequence";
    char m_newline[] = "Newline in string literal";
    char m_invalidCharacter[] = "Invalid character";
    
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
<STR>[^\\\n"]+  {
        /*
        
        for (int i = 73; i < yyleng; i++) {
            yytext[i] = ' ';
        }
        
        */
        
        /*
            strncat(yyval, yytext, 72);
        */
        
        yylval += yytext;
}

<STR>\\n        yylval += '\n';
<STR>\\         yyerror(m_invalidEscape);
<STR>\n         yyerror(m_newline);
[ \t\r\n]       ; // whitespace
[-{};()<>=+*/!,] { return *yytext; }
.               yyerror(m_invalidCharacter);

%%

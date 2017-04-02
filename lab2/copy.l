%{
    #include <string>
    #define YYSTYPE std::string
    #include "copy.tab.h"
    void yyerror(char *s);
    
    char m_invalidEscape[] = "Invalid escape sequence";
    char m_newline[] = "Newline in string literal";
    char m_invalidCharacter[] = "Invalid character";
    
    
    int offset = 0;
    int startOfPunchedCard = 79;
    
%}

%option yylineno
%option noyywrap


%x STR

%%

DBD {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    return DBD;
    }
NAME {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
   return NAME;
}
ACCESS {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    return ACCESS;
}
RMNAME {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    return RMNAME;
}
FRSPC {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    return FRSPC;
}
PSNAME {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
  return PSNAME;
}
PASSWD {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    return PASSWD;
}
DATXEXIT {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    return DATXEXIT;
}
EXIT {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    return EXIT;
}
VERSION {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    return VERSION;
}
PUNCHEDCARD {
    return PUNCHEDCARD;
}


[0-9]+          {
    yylval = yytext;
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    } else {
        return NUM;
    }
//    if (yyleng == 8)
//    return PUNCHEDCARD;
//    else

}
[a-zA-Z_][a-zA-Z0-9_]* {
    yylval = yytext;
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    
    return ID;
}
<STR>[^\\\n"]+  {

        ///*
        
        for (int i = 0; i < yyleng; i++) {
            yytext[i] = ' ';
        }
        BEGIN 0;
        //*/
        
        ///*
            //strncat(yyval, yytext, 72);
        //*/
        
        yylval += yytext;
}

<STR>\\n        yylval += '\n';
<STR>\\         yyerror(m_invalidEscape);
<STR>\n         {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }

    for (int i = 0; i < yyleng; i++) {
    yytext[i] = ' ';
    }
    BEGIN 0;
    //yyerror(m_newline);
}
[ \t\r\n]       {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
}; // whitespace
[-{};()<>=+*/!,] {
    offset += yyleng;
    if (offset > startOfPunchedCard) {
        BEGIN STR;
    }
    return *yytext;
}
.               yyerror(m_invalidCharacter);

%%

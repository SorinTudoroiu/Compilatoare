%{
	#include "y.tab.h"
        #include<stdlib.h>
	#include<string.h>
	
	int lineNo = 1;
	int colNo = 1;
%}

%%
"program"   {ECHO; colNo=colNo+7; return TOK_PROG; }
"var"       { ECHO;colNo=colNo+3; return TOK_VAR;  }
"begin"     {ECHO; colNo=colNo+5; return TOK_BEG; }
"end"       {ECHO; colNo=colNo+3; return TOK_END; }
"integer"   { ECHO;colNo=colNo+7; return TOK_INTEGER; }
"read"      {ECHO; colNo=colNo+4; return TOK_READ; }
"write"     {ECHO; colNo=colNo+5; return TOK_WRI; }
"for"       { ECHO;colNo=colNo+3; return TOK_FOR; }
"do"        { ECHO;colNo=colNo+2; return TOK_DO; }
"to"        {ECHO; colNo=colNo+2; return TOK_TO; }
"+"	    {ECHO; colNo++; return TOK_PLUS; }
"-"	    {ECHO; colNo++; return TOK_MIN; }
"*"	    {ECHO; colNo++; return TOK_MUL; }
"/"	    {ECHO; colNo++; return TOK_DIV; }
"("	    {ECHO; colNo++; return TOK_LEFT; }
")"	    {ECHO; colNo++; return TOK_RIGHT; }
";"	    { ECHO;colNo++; return TOK_PCTVIR; }
":="	    {ECHO; colNo++; return TOK_EGAL; }
":"         { ECHO;colNo++; return TOK_2PNC; }
"," 	    {ECHO; colNo++; return TOK_VIR; }

0|[1-9][0-9]*	{ECHO; yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.val = atoi(yytext); return TOK_INT; }

[a-zA-Z][a-zA-Z0-9]* {ECHO; yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext); return TOK_ID;}

[ ]	    {ECHO; colNo++; }
\r\n        {ECHO; lineNo++; colNo=1; }
\n	    {ECHO; lineNo++; colNo=1; }
.           { colNo++; return TOK_ERROR; }
%%

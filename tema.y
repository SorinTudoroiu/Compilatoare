%{
	#include <stdio.h>
	#include<string.h>
	
	


	int yylex(void);
	int yyerror(const char *msg);
        int EsteCorecta = 1;
	char msg[500];

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;

	
%}
%locations
%token TOK_PROG TOK_VAR TOK_BEG TOK_END TOK_INTEGER TOK_READ TOK_WRI TOK_FOR  TOK_DO TOK_TO
TOK_PLUS TOK_MIN TOK_MUL TOK_DIV TOK_LEFT TOK_RIGHT TOK_PCTVIR TOK_EGAL TOK_ERROR TOK_2PNC  TOK_VIR
%union {int val; char * sir; }

%token <val> TOK_INT
%token <sir> TOK_ID
%type <sir> id_list
%type <val> exp
%type <val> factor
%type <val> term
%type <val> assign

%start prog

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%%

prog      : TOK_PROG prog_name TOK_VAR dec_list TOK_BEG stmt_list TOK_END TOK_ERROR
	  |
	  {EsteCorecta = 0;}
          ;
prog_name : TOK_ID
          ;
dec_list  : dec
          | dec_list TOK_PCTVIR dec
	  ;
dec       : id_list TOK_2PNC type 
{
	char *aux,*p;
	aux=new char[100];
	p=new char[100];
	strcpy(aux,$1);
	
	p=strtok(aux,",");
	while(p)
	{
	if(ts != NULL)
	{
	  if(ts->exists(p) == 0)
	  {
	    ts->add(p);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, p);
	    yyerror(msg);
	   YYERROR;
	  }
	}
	else
	{
	  ts = new TVAR();
	  ts->add(p);
	}
	p=strtok(NULL,",");
	}
}
	  ;
type	  : TOK_INTEGER                             
	  ;
id_list   : TOK_ID  
  	                       
	  | id_list  TOK_VIR TOK_ID

{
strcat($$,",");
strcat($$,$3);


}
	  ;
stmt_list : stmt
	  | stmt_list TOK_PCTVIR stmt
          ;
stmt      : assign
	  | read
          | write
	  | for
	  ;
assign    : TOK_ID TOK_EGAL exp       
		{
		if(ts != NULL)
		{
	 		if(ts->exists($1) == 1)
	  		{
	   			ts->setValue($1, 1);
	  		}
	  		else
	  		{
	    			printf("%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata111!", @1.first_line, @1.first_column, $1);
	   			yyerror(msg);
	  		}
		}
		else
		{
			printf("%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata222!", @1.first_line, @1.first_column, $1);
	  		yyerror(msg);
		}}
	  ;
exp	  : term                      {$$=$1;}
	  | exp TOK_PLUS term         {$$=$1+$3;}
	  | exp TOK_MIN term          {$$=$1+$3;} 
	  
	 
	  ;
term      : factor                    {$$=$1;}
	  | term TOK_MUL factor       {$$=$1*$3;}
	  | term TOK_DIV factor       { 
	  
	  if($3 == 0) 
	  { 
	      EsteCorecta = 0;
	      printf("%d:%d Eroare semantica: Impartire la zero!", @1.first_line, @1.first_column);
	      yyerror(msg);
	      YYERROR;
	  } 
	  else { $$ = $1 / $3; } 
	  }
       	
	  ;
factor    : TOK_ID                                 
	    {
if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    if(ts->getValue($1) == -1)
	    {
	      sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $1);
	      yyerror(msg);
	      YYERROR;
	    }
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}

}
	  | TOK_INT	                            {$$=$1;}
          | TOK_LEFT exp TOK_RIGHT                  {$$=$2;}
	  ;
read      : TOK_READ TOK_LEFT id_list TOK_RIGHT   
{
		if(ts != NULL)
		{
	 		if(ts->exists($3) == 1)
	  		{
	   			ts->setValue($3, 1);
	  		}
	  		else
	  		{
	    			printf("%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata111!", @1.first_line, @1.first_column, $3);
	   			yyerror(msg);
	  		}
		}
		else
		{
			printf("%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata222!", @1.first_line, @1.first_column, $3);
	  		yyerror(msg);
		}} 
	  ;
write     : TOK_WRI TOK_LEFT id_list TOK_RIGHT
{
		if(ts != NULL)
		{
	 		if(ts->exists($3) == 0)
	  		
	  		{
	    			printf("%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata111!", @1.first_line, @1.first_column, $3);
	   			yyerror(msg);
	  		}
		}
		else
		{
			printf("%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata222!", @1.first_line, @1.first_column, $3);
	  		yyerror(msg);
		}}	  ;
for	  : TOK_FOR index_exp TOK_DO body

	  ;
index_exp : TOK_ID TOK_EGAL exp TOK_TO exp  
{
		if(ts != NULL)
		{
	 		if(ts->exists($1) == 1)
	  		{
	   			ts->setValue($1, 1);
	  		}
	  		else
	  		{
	    			printf("%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	   			yyerror(msg);
	  		}
		}
		else
		{
			printf("%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  		yyerror(msg);
		}}        
	  ;
body      : stmt                                  
          | TOK_BEG stmt_list TOK_END
          ;

%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}
	else
	{
		printf("GRESITA\n");
	}	

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}

















  

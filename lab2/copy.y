%{
    #include <iostream>
    #include <list>
    #include <fstream>
    #include <string>
    #include <cstdlib>
    using namespace std;

int global_id = 1;
    const int hash_size = 100;
    extern int yylineno;
    extern int yylex();
    
    void yyerror(char *s) {
        std::cerr << s << ", line " << yylineno << std::endl;
        return;
    }
    
    
    class ParserExpression{
        public:
        ParserExpression *expr, *op;
        std::string name;
        bool args, start, finish, main;
        int id;
        
        ParserExpression(
        std::string name,
        ParserExpression* _expr,
        ParserExpression* op,
        bool main = 0
        ) : id(global_id++), name(name), expr(_expr), op(op), args(0), start(0), finish(0), main(main) {}
        
        ParserExpression() : id(global_id++), name(""), expr(NULL), op(NULL), args(0), start(0), finish(0), main(0) {}
        
        ParserExpression(
        ParserExpression* expr,
        bool args,
        bool start,
        bool finish,
        bool main = 0
        ) : id(global_id++),expr(expr), args(args), start(start), finish(finish), main(main), op(NULL) {}
        
        ParserExpression(
        ParserExpression* expr,
        bool args,
        bool start,
        bool finish,
        ParserExpression* op
        ) : id(global_id++),expr(expr), args(args), start(start), finish(finish), main(0), op(op) {}
        
        ParserExpression(ParserExpression* e) {
            if (e == NULL) {
                name = "";
                expr = NULL;
                op = NULL;
                id = global_id++;
            } else {
                name = e->name;
                id = global_id++;
                start = e->start;
                finish = e->finish;
                args = e->args;
                main = e->main;
                expr = new ParserExpression(e->expr);
                op = new ParserExpression(e->op);
            }
        }
        
        void save_to_file(string file_name) {
            ofstream myfile;
            myfile.open (file_name.c_str());
            int root = -save_to_file_helper(myfile);
            myfile << root << endl;
            myfile.close();
        }
        
        static string to_string(int x) {
            char buffer[33];
            sprintf(buffer, "%d", x);
            return string(buffer);
        }
        
        int save_to_file_helper(ofstream &file) {
            string expr_string = (expr != NULL) ? to_string(expr->save_to_file_helper(file)) : "0";
            string op_string = (op != NULL) ? to_string(op->save_to_file_helper(file)) : "0";
            string name_string = (name.length()) ? name : "NULL";
            string result = "" + to_string(id) + " " + name_string + " " + to_string((int)args) + " " +
            to_string((int)start) + " " + to_string((int)finish) + " " + to_string((int)main) +
            " " +  expr_string + " " + op_string;
            
            file << result << endl;
            return id;
        }
        
        void print(int indent=0) {
            if(args) {
                if(start) std::cout<<"(";
                expr->print(1);
                if(finish) std::cout<<")";
                else if(!main) std::cout << ", ";
                
                if(op != NULL) { if(main && finish) std::cout << std::endl; op->print(); }
            } else {
                if(name == "SEGM") { expr->print(); std::cout << name; }
                else {
                    std::cout << name;
                    if(name != "" && !indent) std::cout << " "; //here was " "
                    if(expr != NULL) expr->print();
                }
                if(op != NULL) { if(main) std::cout << std::endl;
                    op->print(); }
            }
        }
    };
    
    
    class pr : public ParserExpression {
        public:
        pr(ParserExpression* str, ParserExpression* o) {
            name = "SEGM";
            expr = str;
            op = o;
            main = true;
        }
        
        pr(ParserExpression* o) { op = o; expr = NULL; main = true; }
    };
    
    
    class value : public ParserExpression {
        public: value(const std::string& text) { name = text;}
    };
    
    typedef struct {
        std::string str;
        ParserExpression* oper;
        ParserExpression* args;
    } YYSTYPE;
    
    ParserExpression* tree;
    
    void read_from_file(ParserExpression* expr, string file_name) {
        ifstream ifs;
        ifs.open (file_name.c_str());
        string s;
        ParserExpression* hash[hash_size];
        for(int i = 0; i < hash_size; i++) {
            hash[i] = new ParserExpression();
        }
        int root = 0;
        while(ifs.good()) {
            int id;
            string name;
            int args, finish,start,_main;
            int expr, op;
            ifs >> id;
            if (id < 0) {
                root = -id;
                break;
            }
            ifs >> name >> args >> start >> finish >> _main >> expr >> op;
            
            hash[id]->id = id;
            hash[id]->name = (name != "NULL") ? name : "";
            hash[id]->args = args;
            hash[id]->start = start;
            hash[id]->finish = finish;
            hash[id]->main = _main;
            hash[id]->expr = (expr) ? hash[expr] : NULL;
            hash[id]->op = (op) ? hash[op] : NULL;
        }
        expr = hash[root];
    }
    
    #define YYSTYPE YYSTYPE
%}


//for better debuging
%error-verbose

%token NAME PARENT BYTES POINTER FREQ RULES EXIT DSGROUP SSPTR COMPRTN SOURCE RMNAME SEGM
%token NUM ID

%type<str> NUM ID SEGM
%type<oper> OPS /*  OP1 OP2  */ TERM ARG LIST_OP OP
%type<expr> NAME PARENT BYTES POINTER FREQ RULES EXIT DSGROUP SSPTR COMPRTN SOURCE RMNAME
%type<args> ARGS

%%

PROGRAM: OPS                            { /*$1->save_to_file(); delete $1;*/ tree = $1; }
;

OPS:    SEGM LIST_OP                     { $$ = new pr($2); }
|       TERM SEGM LIST_OP                { $$ = new pr($1, $3); }
;


LIST_OP:
LIST_OP','OP { $$ = new pr($1, $3); }
| OP { $$ = new pr($1); }
;

OP:
NAME'='TERM			{ $$ = new ParserExpression("NAME", $3, NULL, true); }
|	PARENT'='TERM		{ $$ = new ParserExpression("PARENT", $3, NULL, true); }
|	BYTES'='TERM		{ $$ = new ParserExpression("BYTES", $3, NULL, true); }
|	POINTER'='TERM		{ $$ = new ParserExpression("POINTER", $3, NULL, true); }
|	FREQ'='TERM		        { $$ = new ParserExpression("FREQ", $3, NULL, true); }
|	EXIT'='TERM			{ $$ = new ParserExpression("EXIT", $3, NULL, true); }
|	DSGROUP'='TERM		{ $$ = new ParserExpression("DSGROUP", $3, NULL, true); }
|	SSPTR'='TERM		{ $$ = new ParserExpression("SSPTR", $3, NULL, true); }
|	COMPRTN'='TERM		{ $$ = new ParserExpression("COMPRTN", $3, NULL, true); }
|	RMNAME'='TERM		{ $$ = new ParserExpression("RMNAME", $3, NULL, true); }
// for testing
//|	NUM                     { $$ = new value($1); }
;
//
//OP1:
//NAME'='TERM OP2			{ $$ = new ParserExpression("NAME", $3, $4, true); }
//|	PARENT'='TERM OP2		{ $$ = new ParserExpression("PARENT", $3, $4, true); }
//|	BYTES'='TERM OP2		{ $$ = new ParserExpression("BYTES", $3, $4, true); }
//|	POINTER'='TERM OP2		{ $$ = new ParserExpression("POINTER", $3, $4, true); }
//|	FREQ'='TERM OP2		        { $$ = new ParserExpression("FREQ", $3, $4, true); }
//|	EXIT'='TERM OP2			{ $$ = new ParserExpression("EXIT", $3, $4, true); }
//|	DSGROUP'='TERM OP2		{ $$ = new ParserExpression("DSGROUP", $3, $4, true); }
//|	SSPTR'='TERM OP2		{ $$ = new ParserExpression("SSPTR", $3, $4, true); }
//|	COMPRTN'='TERM OP2		{ $$ = new ParserExpression("COMPRTN", $3, $4, true); }
//|	RMNAME'='TERM OP2		{ $$ = new ParserExpression("RMNAME", $3, $4, true); }
//// for testing
//|	NUM                     { $$ = new value($1); }
//;
//
//OP2:
//','NAME'='TERM OP2		{ $$ = new ParserExpression("NAME", $4, $5, true); }
//|	','PARENT'='TERM OP2		{ $$ = new ParserExpression("PARENT", $4, $5, true); }
//|	','BYTES'='TERM OP2		{ $$ = new ParserExpression("BYTES", $4, $5, true); }
//|	','POINTER'='TERM OP2		{ $$ = new ParserExpression("POINTER", $4, $5, true); }
//|	','FREQ'='TERM OP2		{ $$ = new ParserExpression("FREQ", $4, $5, true); }
//|	','EXIT'='TERM OP2		{ $$ = new ParserExpression("EXIT", $4, $5, true); }
//|	','DSGROUP'='TERM OP2		{ $$ = new ParserExpression("DSGROUP", $4, $5, true); }
//|	','SSPTR'='TERM OP2		{ $$ = new ParserExpression("SSPTR", $4, $5, true); }
//|	','COMPRTN'='TERM OP2		{ $$ = new ParserExpression("COMPRTN", $4, $5, true); }
//|	','RMNAME'='TERM OP2		{ $$ = new ParserExpression("RMNAME", $4, $5, true); }
//|	',' '*' TERM OP1		{ $$ = $4; }
//|	NUM                     { $$ = new value($1); }
//;

TERM:   NUM                             { $$ = new value($1); }
|       ID                              { $$ = new value($1); }
|       '('ARGS')'                 	{ $$ = new ParserExpression($2, true, true, false, true); }
;

ARGS:                                   { /*$$.clear();*/ }
|       ARG                             { $$ = new ParserExpression($1, true, false, true); }
|       ARG ',' ARGS                    { $$ = new ParserExpression($1, true, false, false, $3); }
;

ARG:	NUM				{ $$ = new value($1); }
|	ID				{ $$ = new value($1); }
;
%%

int main() { 
    yyparse();
    tree->save_to_file("example.txt");
    
    read_from_file(tree, "example.txt");
    tree->print(0);
    
    return 0; 
}

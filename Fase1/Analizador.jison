/* description: Parses and executes mathematical expressions. */

%{
    var contadorTemporales = 1;
    function new_temp (){
        var temp = contadorTemporales;
        contadorTemporales = contadorTemporales + 1;
        return "t" + String(temp);
    }

    var contadorEtiquetas = 1;
    function new_etiqueta (){
        var temp = contadorEtiquetas;
        contadorEtiquetas = contadorEtiquetas + 1;
        return "L" + String(temp);
    }
%}

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
[0-9]+("."[0-9]+)?\b  return 'NUMBER'
"if"                  return 'if'
"else"                  return 'else'
[A-Za-z][A-Za-z0-9]*  return 'IDENTIFIER'
"*"                   return '*'
"/"                   return '/'
"-"                   return '-'
"+"                   return '+'
"("                   return '('
")"                   return ')'
"=="                  return '=='
"="                   return '='
";"                   return ';'
">"                   return '>'
"<"                   return '<'
"("                   return '('
")"                   return ')'
"{"                   return '{'
"}"                   return '}'
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

/* operator associations and precedence */

%left '+' '-'
%left '*' '/'
%left UMINUS

%start S

%options case-insensitive

%% /* language grammar */

S
    : W EOF
        { typeof console !== 'undefined' ? console.log($1.c3d) : print($1);
          return $1; }
    |
    ;

W
    : W V
        {{
            $$ = {
                tmp : "",
                c3d : $1.c3d + $2.c3d
            }
        }}
    | V
        {{
            $$ = {
                tmp : "",
                c3d : $1.c3d
            }
        }}

    ;

V
    : 'if' '(' COMPARACION ')' '{' W ELSEIF
        {{
            $$ = {
                tmp : "",
                c3d : "",
                salida : ""
            }
            var verdadero = new_etiqueta();
            var falso = new_etiqueta();
            var salida = new_etiqueta();
            $$.salida = salida + $7.salida;
            $$.c3d = $1 + " " + $3.c3d + " goto " + verdadero + "\n" 
                    + "goto " + falso + " \n" 
                    + verdadero +":\n" 
                    + $6.c3d
                    + "goto " + salida + "\n"
                    + falso + ":\n"  
                    + $7.c3d
                    + $$.salida + ":"
        }}
    | ASIGNACION
        {{
            $$ = {
                tmp : $1.tmp,
                c3d : $1.c3d
            }
        }}
    ;

ELSEIF
    : '}' 'else' 'if' '(' COMPARACION ')' '{' W ELSEIF
        {{
            $$ = {
                tmp : "",
                c3d : "",
                salida : ""
            }
            var verdadero = new_etiqueta();
            var falso = new_etiqueta();
            var salida = new_etiqueta();
            $$.salida = "," + salida + $9.salida
            $$.c3d = $3 + " " + $5.c3d + " goto " + verdadero + "\n" 
                    + "goto " + falso + " \n" 
                    + verdadero +":\n" 
                    + $8.c3d
                    + "goto " + salida + "\n"
                    + falso + ":\n"
                    + $9.c3d  
        }}
    | '}' 'else' '{' W  '}'
        {{
            $$ = {
                tmp : "",
                c3d : "",
                salida : ""
            }
            $$.c3d = $4.c3d  
        }}
    | '}'
        {$$ = { tmp : "", c3d : "", salida : "" }}
    ;


ASIGNACION   
    : IDENTIFIER '=' E ';'
        {{
            $$ = { 
                    tmp : "",
                    c3d : ""
                }
            $$.c3d = $3.c3d + $1 + "=" + $3.tmp + "\n"
        }}
    ;


E   
    : E '+' T
        {{
            $$ = { 
                    tmp : String(new_temp()),
                    c3d : ""
                  } 
            $$.c3d = $1.c3d + $3.c3d + $$.tmp + "=" + $1.tmp + "+" + $3.tmp + "\n"
        }}
    | E '-' T
        {{
            $$ = { 
                    tmp : String(new_temp()),
                    c3d : ""
                  } 
            $$.c3d = $1.c3d + $3.c3d + $$.tmp + "=" + $1.tmp + "-" + $3.tmp + "\n"
        }}
    | T
        { $$ = { tmp : $1.tmp, c3d : $1.c3d } }
    ;

T   
    : T '*' F
        {{
            $$ = { 
                    tmp : String(new_temp()),
                    c3d : ""
                  } 
            $$.c3d = $1.c3d + $3.c3d + $$.tmp + "=" + $1.tmp + "*" + $3.tmp + "\n"
        }}
    | T '/' F
        {{
            $$ = { 
                    tmp : String(new_temp()),
                    c3d : ""
                  } 
            $$.c3d = $1.c3d + $3.c3d + $$.tmp + "=" + $1.tmp + "/" + $3.tmp + "\n"
        }}
    | F
        { $$ = { tmp : $1.tmp, c3d : $1.c3d } }
    ;

F
    : '(' E ')'
        { $$ = { tmp : $2.tmp, c3d : $2.c3d } }
    | IDENTIFIER
        { $$ = { tmp : yytext, c3d : "" } }
    | NUMBER
        { $$ = { tmp : yytext, c3d : "" } }
    ;

COMPARACION
    : IDENTIFIER '>' IDENTIFIER
        { $$ = { tmp : "", c3d : $1 + $2 + $3 } }
    | IDENTIFIER '<' IDENTIFIER
        { $$ = { tmp : "", c3d : $1 + $2 + $3 } }
    | IDENTIFIER '==' IDENTIFIER
        { $$ = { tmp : "", c3d : $1 + "=" + $3 } }
    ;


%{
(*
   A parser for a simple regular expression syntax over bytes
   used for illustration and testing purposes

   See Lexer.mll for details on the syntax
*)

  open Regexp_type
%}

%token BAR LPAR RPAR STAR PLUS QUESTION EOF
%token <char> CHAR

/* cosmetic preference */
%right BAR

%start main
%type <Regexp_type.t> main
%%

main:
| regexp0 EOF  { $1 }
;

regexp0:
| regexp0 BAR regexp0    { Alt ($1, $3) }
| seq                    { $1 }
|                        { Empty }
;

seq:
| repeat seq           { Seq ($1, $2) }
| repeat               { $1 }
;

repeat:
| regexp1 STAR          { Repeat $1 }
| regexp1 PLUS          { Seq ($1, Repeat $1) }
| regexp1 QUESTION      { Alt ($1, Empty) }
| regexp1               { $1 }
;

regexp1:
| CHAR                      { Char $1 }
| LPAR regexp0 RPAR         { $2 }
;

%%

%{
(*
   A parser for a simple regular expression syntax over bytes
   used for illustration and testing purposes

   See Lexer.mll for details on the syntax
*)

  open Regexp
%}

%token BAR LPAR RPAR STAR PLUS QUESTION DOT LBR RBR DASH CARET EOF
%token <char> CHAR

/* cosmetic preference */
%right BAR

%start main
%type <Regexp.t> main
%%

main:
| regexp0 EOF  { $1 }
;

regexp0:
| regexp0 BAR regexp0    { Alt ($1, $3) }
| seq                    { $1 }
|                        { Epsilon }
;

seq:
| repeat seq           { Seq ($1, $2) }
| repeat               { $1 }
;

repeat:
| regexp1 STAR          { Repeat $1 }
| regexp1 PLUS          { Seq ($1, Repeat $1) }
| regexp1 QUESTION      { Alt ($1, Epsilon) }
| regexp1               { $1 }
;

regexp1:
| CHAR                      { Char (Char_class.singleton $1) }
| LPAR regexp0 RPAR         { $2 }
| DOT                       { Char Char_class.any }
| LBR char_class RBR        { Char $2 }
| LBR CARET char_class RBR  { Char (Char_class.diff Char_class.any $3) }
;

char_class:
| CHAR DASH CHAR char_class { Char_class.union (Char_class.range $1 $3) $4 }
| CHAR char_class           { Char_class.union (Char_class.singleton $1) $2 }
|                           { Char_class.empty }
;
%%

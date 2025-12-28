(*
   A parser for a simple regular expression syntax over bytes
   used for illustration and testing purposes

   Syntax:

   - whitespace is ignored
   - special characters are: | * ? + ( ) [ ] - ^ \
   - if a character is preceded by a backslash, it is interpreted literally

   Examples:

     a* (b|c) d?
     [a-z][^0-9]+
*)

{
  open Parser
}

let whitespace = [' ' '\t' '\r' '\n']

rule token = parse
| whitespace+    { token lexbuf }
| '\\' (_ as c)  { CHAR c }
| '|'            { BAR }
| '('            { LPAR }
| ')'            { RPAR }
| '*'            { STAR }
| '+'            { PLUS }
| '?'            { QUESTION }
| '.'            { DOT }
| '['            { LBR }
| ']'            { RBR }
| '-'            { DASH }
| '^'            { CARET }
| _ as c         { CHAR c }
| eof            { EOF }

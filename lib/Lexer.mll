(*
   A parser for a simple regular expression syntax over bytes
   used for illustration and testing purposes

   Syntax:

   - whitespace is ignored
   - special characters are: | * ? + ( ) \
   - if a character is preceded by a backslash, it is interpreted literally

   Example:

     a* (b|c) d?
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
| _ as c         { CHAR c }
| eof            { EOF }

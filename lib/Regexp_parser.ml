(*
   A simplified regexp language for testing purposes
*)

let of_string_exn str =
  let lexbuf = Lexing.from_string str in
  Parser.main Lexer.token lexbuf

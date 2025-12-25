(*
   A tree representing a regular expression over bytes
*)

(* The type of a regular expression *)
type t = Regexp_type.t =
  | Empty
  | Char of char
  | Seq of t * t
  | Alt of t * t
  | Repeat of t
[@@deriving show { with_path = false }]

let of_string_exn str =
  let lexbuf = Lexing.from_string str in
  Parser.main Lexer.token lexbuf

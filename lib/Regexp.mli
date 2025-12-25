(**
   A tree representing a regular expression over bytes
*)

(** The type of a regular expression

{v
   a   : Char 'a'
   ab  : Seq (Char 'a', Char 'b')
   a*  : Repeat (Char 'a')
   a|b : Alt (Char 'a', Char 'b')
   a+  : Seq (Char 'a', Repeat (Char 'a'))
   a?  : Alt (Char 'a', Empty)
v}
*)
type t = Regexp_type.t =
  | Empty
  | Char of char
  | Seq of t * t
  | Alt of t * t
  | Repeat of t
[@@deriving show]

val of_string_exn : string -> t

(**
   A tree representing a regular expression over bytes
*)

(** The type of a regular expression

{v
   let a = Char_class.singleton 'a'
   let b = Char_class.singleton 'b'

   a   : Char a
   ab  : Seq (Char a, Char b)
   a*  : Repeat (Char a)
   a|b : Alt (Char a, Char b)
   a+  : Seq (Char a, Repeat (Char a))
   a?  : Alt (Char a, Epsilon)
v}
*)
type t =
  | Epsilon (** match the empty sequence *)
  | End_of_input (** match at the end of the string; useful in prefix mode *)
  | Char of Char_class.t (** match any input character in the character
                             class *)
  | Seq of t * t (** match two patterns in sequence *)
  | Alt of t * t (** match either one pattern or the other *)
  | Repeat of t (** match a pattern repeatedly, zero times or more *)
[@@deriving show { with_path = false }]

(** Match the pattern once or multiple times ("+" quantifier) *)
val repeat1 : t -> t

(** Match the pattern at most once ("?" quantifier) *)
val opt : t -> t

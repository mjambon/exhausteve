(*
   A tree representing a regular expression over bytes
*)

(* The type of a regular expression *)
type t =
  | Epsilon
  | Char of Char_class.t
  | Seq of t * t
  | Alt of t * t
  | Repeat of t
[@@deriving show { with_path = false }]

let repeat1 re = Seq (re, Repeat re)

let opt re = Alt (re, Epsilon)

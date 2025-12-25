(* Same as Regexp.t

   Having this type definition alone here allows the Regexp module to
   expose parsing functions alongside the redefinition of t.
*)
type t =
  | Empty
  | Char of char
  | Seq of t * t
  | Alt of t * t
  | Repeat of t

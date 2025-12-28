(** Map a character to a unique character class. *)

type t

(** The zero-based index of a character class *)
type symbol_id = private int

(** A char class with its index within a partition *)
type symbol = private {
  id: symbol_id;
  chars: Char_class.t;
}

(** Take a list of character classes S and return the partition P
    of the alphabet (the 256 bytes) into character classes such that
    for any p in P, all the characters in p occur in the same character
    classes in S.

    The input S is normally all the character classes extracted from
    the root regular expression. The partition is a grouping of characters
    into a smaller alphabet to be used to represent automaton transitions.
*)
val partition : Char_class.t list -> t

(** Return the number N of character classes in the partition of the bytes,
    1 <= N <= 256. This is the size of the alphabet used for automaton
    transitions. *)
val length : t -> int

(** Return all the valid symbols *)
val alphabet : t -> symbol list

(** Associate a character with its char_class in the partition *)
val assoc : t -> char -> symbol

(** Standard operations needed to feed Set.Make, Map.Make,
    and Hashtbl.Make functors.

    We could use a functor to ensure statically that two char_class
    are indeed from the same partition but it's overkill. *)
module Symbol : sig
  type t = symbol
  val compare : t -> t -> int
  val equal : t -> t -> bool
  val hash : t -> int
  val show : t -> string
end

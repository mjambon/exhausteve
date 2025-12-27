(**
   Character classes

   A character class is a set of a characters that are handled identically.
   The term is used in two different but related contexts:
   - In a regular expression, it indicates that one of the characters
     of the set must match an input character.
   - In the automata derived from a regular expression (DFA, NFA),
     instead of having transitions that are identical for many characters,
     these characters with identical transitions are grouped into character
     classes which are then treated as one character. This drastically
     reduces the number of edges in the graph, making the computation of
     the automata fast and easy to debug.
*)

(** A character class is a set of characters (bytes of type [char]) *)
type t

(** Return the elements of the character class in order *)
val elements : t -> char list

(** Show the elements in a compact representation using ranges *)
val show : t -> string

(** An empty character class can be used in a regular expression to
    represent the empty language as it is guaranteed to never match
    any input. *)
val is_empty : t -> bool

(** Add an element *)
val singleton : char -> t
val add : char -> t -> t

(** A set of consecutive bytes *)
val range : char -> char -> t

(** Set operations to construct character classes *)
val union : t -> t -> t
val inter : t -> t -> t
val diff : t -> t -> t

(** Predefined character classes for tests and such *)
val any : t
val empty : t
val alpha : t
val digit : t

(** Whether a character belongs to a character class *)
val mem : char -> t -> bool

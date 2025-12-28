(** Analyze the DFA for exhaustiveness *)

(** Convert a regular expression into a DFA usable for matching or
    for analysis. To get all the DFA states or to check the intermediate
    NFA, use the NFA and DFA modules directly instead. *)
val compile : Regexp.t -> DFA.t

(** Check whether a DFA starting from the given state can match
    any input. If not, an example of non-matching input is returned. *)
val is_exhaustive : DFA.t -> (unit, string) Result.t

(** Test whether a string matches a regexp. This isn't very efficient,
    it's for testing purposes. *)
val matches : DFA.t -> string -> bool

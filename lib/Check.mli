(** Analyze the DFA for exhaustiveness *)

(** Check whether a DFA starting from the given state can match
    any input. If not, an example of non-matching input is returned. *)
val is_exhaustive_dfa : DFA.state -> (unit, string) Result.t

(** Same as [is_exhaustive_dfa] but includes the steps to build the
    NFA from the regular expression and the conversion to a DFA. *)
val is_exhaustive_regexp : Regexp.t -> (unit, string) Result.t

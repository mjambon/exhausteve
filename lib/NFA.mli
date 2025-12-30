(** NFA representing a regular expression *)

type transition =
  | Epsilon
      (** an empty transition; those aren't allowed in DFAs *)
  | Input of Char_partition.symbol
      (** a character of input being consumed *)
  | End_of_input
      (** end of input; treated mostly like an input character *)

type state_id = private int

val show_state_id : state_id -> string

(** A state in the automaton i.e. a node in a directed graph with labeled
    edges.

    A state is said final or accepting if it marks the successful end
    of the match between the pattern and the input data.

    A transition is an arrow that usually takes us to another state while
    at the same time consuming a character of input. In an NFA, it's also
    possible to not consume any character of input and such transitions
    are called epsilon transitions. It's also possible to be sent to the
    same state while consuming a character of input.

    In an NFA, multiple identical transitions can exist and lead to
    different states.
*)
type state = {
  id: state_id;
    (** Unique state/node identifier *)
  final: bool;
    (** Whether this state is accepting/final *)
  transitions: (transition, state) Hashtbl.t;
    (** A transition links to one or more states. Use [Hashtbl.find_all]
        to access them. *)
}

(** The automaton defined over symbols that are groupings of equivalent
    characters. *)
type t = {
  initial_state: state;
  states: state array;
  char_partition: Char_partition.t;
  mode: Conf.matching_mode;
}

(** Build an NFA equivalent to the given regular expression.

    The matching mode specifies whether we want to match the whole input
    string or if leaving some input unmatched is acceptable. *)
val make : Conf.matching_mode -> Regexp.t -> t

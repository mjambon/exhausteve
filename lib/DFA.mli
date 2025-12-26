(** DFA (deterministic finite automaton) representing a regular expression *)

type transition =
  | Input of char
  | End_of_input

type state_id = private int

val show_state_id : state_id -> string

module NFA_states : Set.S with type elt = NFA.state

val show_nfa_states : NFA_states.t -> string

(** A DFA state. The original unique ID is a set of NFA state IDs.
    The [id] field is a unique int generated from a counter. *)
type state = {
  id: state_id;
  nfa_states: NFA_states.t;
  final: bool;
  transitions: (transition, state) Hashtbl.t;
}

val show_state : state -> string

type t = state * state array

val make : NFA.state -> t

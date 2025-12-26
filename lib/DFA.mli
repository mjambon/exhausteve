(** DFA (deterministic finite automaton) representing a regular expression *)

type transition =
  | Input of char
  | End_of_input

type state_id = private int

module NFA_states : Set.S

(** A DFA state. The original unique ID is a set of NFA state IDs.
    The [id] field is a unique int generated from a counter. *)
type state = {
  id: state_id;
  nfa_states: NFA_states.t;
  final: bool;
  transitions: (transition, state) Hashtbl.t;
}

type t = state * state array

val make : NFA.state -> t

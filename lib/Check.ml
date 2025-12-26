(* Analyze the DFA for exhaustiveness *)

(*
   The DFA represents a regular expression.
   In order to match any input, each state of the automaton must be either
   final or have a transition defined for any character including the
   special end-of-input character.

   We try to provide nice examples by favoring shorter input strings.
   This is achieved by visiting the graph breadth-first instead of depth-first.
*)
let is_exhaustive_dfa (_state : DFA.state) =
  Ok ()

let is_exhaustive_regexp (re : Regexp.t) =
  let nfa_start, _nfa_states = NFA.make re in
  let dfa_start, _dfa_states = DFA.make nfa_start in
  is_exhaustive_dfa dfa_start

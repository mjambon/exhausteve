(* DFA (deterministic finite automaton) representing a regular expression *)

open Printf

type transition =
  | Input of Char_partition.symbol
  | End_of_input

type state_id = int

let compare_state_id = Int.compare

(* 42 -> "D42" to avoid confusion with NFA states named Nxxx *)
let show_state_id id = sprintf "D%i" id

let get_alphabet p =
  End_of_input ::
  (Char_partition.alphabet p |> List.map (fun symbol -> Input symbol))

let nfa_trans_of_dfa_trans (trans : transition) : NFA.transition =
  match trans with
  | Input c -> Input c
  | End_of_input -> End_of_input

(* A set of NFA state IDs, identifying a DFA state *)
module NFA_states = Set.Make (struct
    type t = NFA.state
    let compare (a : NFA.state) (b : NFA.state) = compare a.id b.id
end)

let hash_nfa_states (x : NFA_states.t) =
  (* Get the elements as a sorted list before hashing them *)
  Hashtbl.hash (NFA_states.elements x)

let union_of_nfa_transitions nfa_states =
  let tbl = Hashtbl.create 10 in
  NFA_states.iter (fun (state : NFA.state) ->
    Hashtbl.iter (fun trans dst_state ->
      Hashtbl.add tbl trans dst_state
    ) state.transitions
  ) nfa_states;
  tbl

(* A DFA state. The original unique ID is a set of NFA state IDs.
   The 'id' field is a unique int generated from a counter. *)
type state = {
  id: state_id;
  nfa_states: NFA_states.t;
  final: bool;
  transitions: (transition, state) Hashtbl.t;
}

type t = {
  initial_state: state;
  states: state array;
  char_partition: Char_partition.t;
}

let compare_state a b =
  compare_state_id a.id b.id

let show_nfa_states ?max_len nfa_states =
  let all = NFA_states.elements nfa_states in
  (match max_len with
   | Some n when List.length all > n ->
       (List.take n all
        |> List.map (fun (state : NFA.state) -> NFA.show_state_id state.id)
        |> String.concat ", ")
       ^ ", ..."
   | None
   | Some _ ->
       all
       |> List.map (fun (state : NFA.state) -> NFA.show_state_id state.id)
       |> String.concat ", "
  )
  |> sprintf "{%s}"

let show_state state =
  sprintf "%s %s (%i transitions)%s"
    (show_state_id state.id)
    (show_nfa_states state.nfa_states)
    (Hashtbl.length state.transitions)
    (if state.final then " final"
     else "")

(* A hash table module for mapping DFA state IDs to anything *)
module NFA_states_tbl = Hashtbl.Make (struct
  type t = NFA_states.t
  let hash = hash_nfa_states
  let equal = NFA_states.equal
end)

(* Produce a set of all the states reachable via zero or more
   epsilon transitions *)
let epsilon_closure (state : NFA.state) : NFA_states.t =
  let rec visit visited state =
    if NFA_states.mem state visited then
      visited
    else
      let visited = NFA_states.add state visited in
      let dst_states = Hashtbl.find_all state.transitions Epsilon in
      List.fold_left visit visited dst_states
  in
  visit NFA_states.empty state

let merge_dst_nfa_states
    (nfa_states_before_epsilon_closure : NFA.state list) =
  List.fold_left (fun states state ->
    NFA_states.union states (epsilon_closure state)
  ) NFA_states.empty nfa_states_before_epsilon_closure

let make (nfa : NFA.t) : t =
  let state_counter = ref 0 in

  let new_id () =
    let id = !state_counter in
    incr state_counter;
    id
  in

  let all_states = NFA_states_tbl.create 100 in

  (* Get or create a DFA state from a set of NFA states *)
  let get_dfa_state nfa_states =
    match NFA_states_tbl.find_opt all_states nfa_states with
    | Some state -> state
    | None ->
        let id = new_id () in
        let final =
          NFA_states.exists
            (fun (state : NFA.state) -> state.final) nfa_states in
        let state = {
          id;
          nfa_states;
          final;
          transitions = Hashtbl.create 10
        } in
        NFA_states_tbl.add all_states nfa_states state;
        state
  in

  let alphabet = get_alphabet nfa.char_partition in

  let rec translate_nfa_states (dfa_state : state) =
    (* printf "translate %s\n" (show_state dfa_state); *)
    let nfa_transitions = union_of_nfa_transitions dfa_state.nfa_states in
    (* Iterate over the alphabet *)
    List.iter (fun possible_trans ->
      let dst_nfa_states =
        Hashtbl.find_all nfa_transitions (nfa_trans_of_dfa_trans possible_trans)
        |> merge_dst_nfa_states
      in
      (* For now, avoid creating transitions to the dead state *)
      if not (NFA_states.is_empty dst_nfa_states) then
        let dst_dfa = get_dfa_state dst_nfa_states in
        if not (Hashtbl.mem dfa_state.transitions possible_trans) then (
          Hashtbl.add dfa_state.transitions possible_trans dst_dfa;
          translate_nfa_states dst_dfa
        )
    ) alphabet
  in

  let nfa_starts = merge_dst_nfa_states [nfa.initial_state] in
  let dfa_start = get_dfa_state nfa_starts in
  translate_nfa_states dfa_start;

  let state_array =
    NFA_states_tbl.fold (fun _id state acc -> state :: acc) all_states []
    |> List.sort (fun a b -> compare a.id b.id)
    |> Array.of_list
  in
  Array.iteri (fun i state -> assert (state.id = i)) state_array;

  { initial_state = dfa_start;
    states = state_array;
    char_partition = nfa.char_partition }

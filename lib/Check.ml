(* Analyze the DFA for exhaustiveness *)

let compile matching_mode re =
  let nfa = NFA.make matching_mode re in
  let dfa = DFA.make nfa in
  dfa

module DFA_states = Set.Make (struct
    type t = DFA.state
    let compare = DFA.compare_state
end)

module DFA_state_map = Map.Make (struct
    type t = DFA.state
    let compare = DFA.compare_state
end)

let string_of_path (path : Char_partition.symbol list) =
  path
  |> List.rev
  |> List.map (fun (symbol: Char_partition.symbol) ->
    match Char_class.choose_opt symbol.chars with
    | None ->
        (* A symbol may not be created for an empty character class *)
        assert false
    | Some char -> char
  )
  |> List.to_seq
  |> String.of_seq

exception Missing_transition of DFA.transition

let get_possible_transitions (p : Char_partition.t) =
  DFA.End_of_input
  :: List.map (fun symbol -> DFA.Input symbol) (Char_partition.alphabet p)

let find_missing_transition possible_transitions (state : DFA.state) =
  if state.final then
    None
  else
    let transitions = state.transitions in
    try
      List.iter (fun trans ->
        if not (Hashtbl.mem transitions trans) then
          raise (Missing_transition trans)
      ) possible_transitions;
      None
    with Missing_transition trans -> Some trans

exception Found_string of string

(*
   The DFA represents a regular expression.

   In order to match any input, each state of the automaton must be either
   final or have a transition defined for any character including the
   special end-of-input character.

   We try to provide nice examples by favoring shorter input strings.
   This is achieved by visiting the graph breadth-first instead of depth-first.
*)
let is_exhaustive (dfa : DFA.t) =
  let possible_transitions = get_possible_transitions dfa.char_partition in
  let rec bfs_visit
      visited
      (paths : Char_partition.symbol list DFA_state_map.t) =
    let visited, extended_paths =
      DFA_state_map.fold (fun state path (visited, extended_paths) ->
        let visited = DFA_states.add state visited in
        if state.final then
          (visited, extended_paths)
        else
          match find_missing_transition possible_transitions state with
          | Some trans ->
              (* We found a missing transition. Adding this character or eof to
                 the current path makes it a non-matching input *)
              let failing_path =
                match trans with
                | End_of_input -> path
                | Input c -> c :: path
              in
              raise (Found_string (string_of_path failing_path))
          | None ->
              (* We didn't find a missing transition. Follow the transitions
                 that land on a state that hasn't already been visited,
                 extending the path with the character associated with
                 the transition. *)
              let extended_paths =
                Hashtbl.fold (fun trans dst_state extended_paths ->
                  match (trans : DFA.transition) with
                  | End_of_input -> extended_paths
                  | Input c ->
                      if not (DFA_states.mem dst_state visited)
                      && not (DFA_state_map.mem dst_state extended_paths) then
                        DFA_state_map.add dst_state (c :: path) extended_paths
                      else
                        extended_paths
                ) state.transitions extended_paths
              in
              (visited, extended_paths)
      ) paths (visited, DFA_state_map.empty)
    in
    if DFA_state_map.is_empty extended_paths then
      (* We visited all the reachable nodes *)
      ()
    else
      bfs_visit visited extended_paths
  in
  try
    bfs_visit DFA_states.empty (DFA_state_map.singleton dfa.initial_state []);
    Ok ()
  with Found_string example ->
    Error example

let matches (dfa : DFA.t) str =
  let rec matches (state : DFA.state) chars =
    if state.final then
      true
    else
      match chars with
      | [] ->
          (match Hashtbl.find_opt state.transitions End_of_input with
           | Some state -> state.final
           | None -> false)
      | char :: chars ->
          let symbol = Char_partition.assoc dfa.char_partition char in
          match Hashtbl.find_opt state.transitions (Input symbol) with
          | Some state -> matches state chars
          | None -> false
  in
  let chars =
    str
    |> String.to_seq
    |> List.of_seq
  in
  matches dfa.initial_state chars

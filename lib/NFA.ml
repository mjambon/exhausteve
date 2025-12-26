(* NFA representing a regular expression *)

open Printf

type transition =
  | Epsilon
  | Input of char
  | End_of_input

type state_id = int

(* 42 -> "N42" to avoid confusion with DFA states named Dxxx *)
let show_state_id x = sprintf "N%i" x

(* A state in the automaton i.e. a node in a directed graph with labeled
   edges.

   A state is said "final" or "accepting" if it marks the successful end
   of the match between the pattern and the input data.

   A transition is an arrow that takes us to another state while at the
   same time consuming a character of input. In an NFA, it's also possible
   to not consume any character of input and such transitions are called
   epsilon transitions.

   In an NFA, multiple identical transitions can exist and lead to
   different states.
*)
type state = {
  (* Unique state/node identifier *)
  id: state_id;
  (* Whether this state is accepting/final *)
  final: bool;
  (* A transition links to one or more states *)
  transitions: (transition, state) Hashtbl.t;
}

type t = state * state array

let make (re : Regexp.t) : t =
  let state_counter = ref 0 in

  let new_id () =
    let res = !state_counter in
    incr state_counter;
    res
  in

  let all_states = Hashtbl.create 100 in

  let create_state ?(final = false) () =
    let id = new_id () in
    let state = {
      id;
      final;
      transitions = Hashtbl.create 10
    } in
    Hashtbl.add all_states id state;
    state
  in

  let add_transition from_state trans to_state =
    (* There may be multiple values under the same key (unlike in a DFA),
       to be retrieved with Hashtbl.find_all *)
    match trans with
    (* Avoid infinite loops: staying on the same state is only allowed
       when consuming input *)
    | Epsilon when from_state.id = to_state.id ->
        ()
    | _ ->
        Hashtbl.add from_state.transitions trans to_state
  in

  (* Translate the regular expression to take us from the current state
     to the next state after this regexp *)
  let rec translate_regexp cur_state (re : Regexp.t) next_state =
    match re with
    | Empty ->
        add_transition cur_state Epsilon next_state
    | Char c ->
        add_transition cur_state (Input c) next_state
    | Seq (a, b) ->
        let state = create_state () in
        translate_regexp cur_state a state;
        translate_regexp state b next_state
    | Alt (a, b) ->
        translate_regexp cur_state a next_state;
        translate_regexp cur_state b next_state
    | Repeat a ->
        translate_regexp cur_state a cur_state;
        add_transition cur_state Epsilon next_state
  in
  let initial_state = create_state () in
  let penultimate_state = create_state () in
  let final_state = create_state ~final:true () in
  add_transition penultimate_state End_of_input final_state;
  translate_regexp initial_state re penultimate_state;
  let state_array =
    Hashtbl.fold (fun _id state acc -> state :: acc) all_states []
    |> List.sort (fun a b -> compare a.id b.id)
    |> Array.of_list
  in
  Array.iteri (fun i state -> assert (state.id = i)) state_array;
  initial_state, state_array

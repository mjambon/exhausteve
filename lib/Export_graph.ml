(*
   Export automata to the DOT graph format for visualization with Graphviz
*)

open Printf

type state = {
  id : string;
  final : bool;
}

type transition = {
  from: string;
  to_: string;
  label: string;
}

(* Escape control characters only, preserve newlines *)
let escape_char c =
  match c with
  | '\\' -> {|\\|}
  | '\"' -> {|\"|}
  | '\n' -> {|\n|}
  | '\000'..'\031' -> sprintf "\\\\x%02X" (Char.code c)
  | c -> String.make 1 c

(* Escape control characters only, preserve Greek letters and such.
   Add quotes. *)
let quote str =
  str
  |> String.to_seq
  |> Seq.map escape_char
  |> List.of_seq
  |> String.concat ""
  |> sprintf {|"%s"|}

let export_dot oc states transitions =
  fprintf oc "digraph {\n";
  List.iter (fun state ->
    let shape =
      if state.final then
        "doublecircle"
      else
        "circle"
    in
    fprintf oc "  %s [shape=%s];\n"
      (quote state.id) shape
  ) states;
  List.iter (fun trans ->
    fprintf oc "  %s -> %s [label=%s];\n"
      (quote trans.from) (quote trans.to_) (quote trans.label)
  ) transitions;
  fprintf oc "}\n"

let label_of_nfa_transition (x : NFA.transition) =
  match x with
  | Epsilon -> "ε"
  | Input c -> Char_partition.Symbol.show c
  | End_of_input -> "eof"

let label_of_dfa_transition (x : DFA.transition) =
  match x with
  | Input c -> Char_partition.Symbol.show c
  | End_of_input -> "eof"

let nfa_name (state : NFA.state) =
  NFA.show_state_id state.id

let dfa_name (state : DFA.state) =
  sprintf "%s\n%s"
    (DFA.show_state_id state.id)
    (DFA.show_nfa_states state.nfa_states)

let export_nfa oc states =
  let nodes, nested_edges =
    states
    |> Array.to_list
    |> List.map (fun (state : NFA.state) ->
      let from = nfa_name state in
      let transitions =
        Hashtbl.fold (fun (trans : NFA.transition) (state : NFA.state) acc ->
          { from;
            to_ = nfa_name state;
            label = label_of_nfa_transition trans } :: acc
        ) state.transitions []
      in
      ({ id = from; final = state.final },
       transitions
      )
    )
    |> List.split
  in
  export_dot oc nodes (List.flatten nested_edges)

let export_dfa oc states =
  let nodes, nested_edges =
    states
    |> Array.to_list
    |> List.map (fun (state : DFA.state) ->
      let from = dfa_name state in
      let transitions =
        Hashtbl.fold (fun (trans : DFA.transition) (state : DFA.state) acc ->
          { from;
            to_ = dfa_name state;
            label = label_of_dfa_transition trans } :: acc
        ) state.transitions []
      in
      ({ id = from; final = state.final },
       transitions
      )
    )
    |> List.split
  in
  export_dot oc nodes (List.flatten nested_edges)

let with_output_file file func =
  let oc = open_out file in
  Fun.protect
    ~finally:(fun () -> close_out_noerr oc)
    (fun () -> func oc)

let export_nfa_to_file file states =
  with_output_file file (fun oc -> export_nfa oc states)

let export_dfa_to_file file states =
  with_output_file file (fun oc -> export_dfa oc states)

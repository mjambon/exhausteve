(*
   Export automata to the DOT graph format for visualization with Graphviz
*)

open Printf

type state = {
  id : int;
  final : bool;
}

type transition = {
  from: int;
  to_: int;
  label: string;
}

let export_dot oc states transitions =
  fprintf oc "digraph {\n";
  List.iter (fun state ->
    let shape =
      if state.final then
        "doublecircle"
      else
        "circle"
    in
    fprintf oc "  S%i [shape=%s];\n" state.id shape
  ) states;
  List.iter (fun trans ->
    fprintf oc "  S%i -> S%i [label=\"%s\"];\n" trans.from trans.to_ trans.label
  ) transitions;
  fprintf oc "}\n"

let label_of_nfa_transition (x : NFA.transition) =
  match x with
  | Epsilon -> "ε"
  | Input c -> sprintf "%C" c
  | End_of_input -> "eof"

let export_nfa oc states =
  let nodes, nested_edges =
    states
    |> Array.to_list
    |> List.map (fun (state : NFA.state) ->
      let from = (state.id :> int) in
      let transitions =
        Hashtbl.fold (fun (trans : NFA.transition) (state : NFA.state) acc ->
          { from;
            to_ = (state.id :> int);
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

let with_output_file file func =
  let oc = open_out file in
  Fun.protect
    ~finally:(fun () -> close_out_noerr oc)
    (fun () -> func oc)

let export_nfa_to_file file states =
  with_output_file file (fun oc -> export_nfa oc states)

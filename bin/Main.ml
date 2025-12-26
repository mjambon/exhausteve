(*
   Entry point of the executable
*)

open Exhausteve

(*
   No fancy command-line parsing. Read a regular expression in the supported
   syntax from stdin.
*)
let main () =
  let re = In_channel.input_all stdin |> Regexp.of_string_exn in
  print_endline (Regexp.show re);
  let nfa_start, nfa_states = NFA.make re in
  let _dfa_start, dfa_states = DFA.make nfa_start in
  Export_graph.export_nfa_to_file "nfa.dot" nfa_states;
  Export_graph.export_dfa_to_file "dfa.dot" dfa_states

let () = main ()

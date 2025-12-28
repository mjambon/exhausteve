(*
   Entry point of the executable
*)

open Printf
open Exhausteve

(*
   No fancy command-line parsing. Read a regular expression in the supported
   syntax from stdin.
*)
let main () =
  let re = In_channel.input_all stdin |> Regexp_parser.of_string_exn in
  print_endline (Regexp.show re);
  let nfa = NFA.make re in
  let dfa = DFA.make nfa in
  Export_graph.export_nfa_to_file "nfa.dot" nfa.states;
  Export_graph.export_dfa_to_file "dfa.dot" dfa.states;
  match Check.is_exhaustive dfa with
  | Ok () ->
      printf "The provided regular expression is exhaustive.\n"
  | Error example ->
      printf "\
The provided regular expression is not exhaustive.
Here is an example of nonmatching input:
%S
"
        example

let () = main ()

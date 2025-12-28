(*
   Entry point of the executable
*)

open Printf
open Cmdliner
open Exhausteve

let mode_term =
  let info =
    Arg.info ["mode"]
      ~docv:"MODE"
      ~doc:"Matching mode. In the default 'full' mode, the pattern must \
           match the entire input string. In 'prefix' mode, the pattern \
           only needs to match a prefix of the input."
  in
  Arg.value (Arg.opt (Arg.enum ["full", Conf.Full;
                                "prefix", Conf.Prefix]) Conf.Full info)

let cmdline_term run =
  let combine mode =
    let conf : Conf.t = {
      matching_mode = mode;
    } in
    run conf
  in
  Term.(const combine
        $ mode_term
       )

let doc =
  "check a classic regular expression for exhaustiveness"

let man = [
  (* 'NAME' and 'SYNOPSIS' sections are inserted here by cmdliner. *)

  `S Manpage.s_description;
  `P "Read a regular expression from standard input and print information \
      about it, including whether it can fail to match some input string \
      i.e. whether it is equivalent to '.*'. \
      If there exists some input it can't match, an example \
      is provided.";
  `P "Syntax: whitespace is ignored. The usual '*', '+', '?',
      '|' are supported. Character classes using the usual bracket notation \
      and a leading caret for complement are supported. Any character \
      preceded by a backslash is interpreted literally and the backslash \
      is ignored. Special characters must be escaped \
      with a backslash to match literally. The special characters are: \
      '|' '*' '?' '+' '(' ')' '[' ']' '-' '^' '.', backslash, whitespace \
      (SPACE HT CR LF). See example in the EXAMPLES section";

  (* 'ARGUMENTS' and 'OPTIONS' sections are inserted here by cmdliner. *)

  `S Manpage.s_examples; (* standard 'EXAMPLES' section *)
  `Pre {|\$ echo '.? | [^h]. | .[^i] | ...+' | exhausteve
The provided regular expression is not exhaustive.
Here is an example of nonmatching input:
"hi"
|};

  `S Manpage.s_authors;
  `P "Martin Jambon <martin@mjambon.com>";

  `S Manpage.s_bugs;
  `P "Contribute by reporting suggestions and problems \
      at https://github.com/mjambon/exhausteve";
]

let run (conf : Conf.t) =
  let re = In_channel.input_all stdin |> Regexp_parser.of_string_exn in
  let oc = open_out "regexp.txt" in
  fprintf oc "%s\n" (Regexp.show re);
  close_out oc;
  let nfa = NFA.make conf.matching_mode re in
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

let parse_command_line_and_run run =
  let info =
    Cmd.info
      ~doc
      ~man
      "exhausteve"
  in
  Cmd.v info (cmdline_term run) |> Cmd.eval |> exit

let safe_run conf =
  try run conf
  with
  | Failure msg ->
      eprintf "Error: %s\n%!" msg;
      exit 1
  | e ->
      let trace = Printexc.get_backtrace () in
      eprintf "Error: exception %s\n%s%!"
        (Printexc.to_string e)
        trace

let main () =
  Printexc.record_backtrace true;
  parse_command_line_and_run safe_run

let () = main ()

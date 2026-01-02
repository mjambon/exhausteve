(*
   Unit tests for exhausteve
*)

open Printf
open Exhausteve

let show_mode (mode: Conf.matching_mode) =
  match mode with
  | Full -> "full"
  | Prefix -> "prefix"

(* Test regexp matching *)
let test_match mode ?name regexp_str input matches =
  let name, cat =
    match name with
    | None -> sprintf "%S" input, []
    | Some name -> name, [sprintf "%S" input]
  in
  Testo.create
    name
    ~category:(["match"; show_mode mode; regexp_str] @ cat)
    (fun () ->
       printf "regexp: %s\n" regexp_str;
       printf "input: %s\n" input;
       let re = Regexp_parser.of_string_exn regexp_str in
       let dfa = Check.compile mode re in
       let res = Check.matches dfa input in
       Alcotest.(check bool) "" matches res
    )

let test_match_full = test_match Full
let test_match_prefix = test_match Prefix

type matcher_kind =
  | Shortest_match
  | Longest_match

let show_matcher = function
  | Shortest_match -> "shortest match"
  | Longest_match -> "longest match"

let get_matcher = function
  | Shortest_match -> Check.shortest_match
  | Longest_match -> Check.longest_match

let test_prefix_match matcher_kind ?name regexp_str input expected_result =
  let name, cat =
    match name with
    | None -> sprintf "%S" input, []
    | Some name -> name, [sprintf "%S" input]
  in
  Testo.create
    name
    ~category:(["match"; "prefix"; show_matcher matcher_kind; regexp_str] @ cat)
    (fun () ->
       printf "regexp: %s\n" regexp_str;
       printf "input: %s\n" input;
       let re = Regexp_parser.of_string_exn regexp_str in
       let dfa = Check.compile Conf.Prefix re in
       let res = (get_matcher matcher_kind) dfa input in
       Alcotest.(check (option string)) "" expected_result res
    )

let test_shortest_match = test_prefix_match Shortest_match
let test_longest_match = test_prefix_match Longest_match

(* Test regexp exhaustiveness *)
let test_exhaustiveness mode ?name regexp_str expected_result =
  let name, cat =
    match name with
    | None -> regexp_str, []
    | Some name -> name, [regexp_str]
  in
  Testo.create
    name
    ~category:(["exhaustiveness"; show_mode mode] @ cat)
    (fun () ->
       printf "regexp: %s\n" regexp_str;
       let re = Regexp_parser.of_string_exn regexp_str in
       let dfa = Check.compile mode re in
       let result = Check.is_exhaustive dfa in
       match expected_result with
       | Ok () ->
           printf "expected result: exhaustive\n";
           Alcotest.(check bool) "" true (result = expected_result)
       | Error expected_example ->
           printf "expected result: not exhaustive\n";
           printf "expected example of nonmatching input: %S\n"
             expected_example;
           match result with
           | Ok () -> Alcotest.fail "incorrectly reported as exhaustive"
           | Error example ->
               printf "correctly reported as nonexhaustive.\n";
               printf "example of nonmatching input: %S\n" example;
               (* The expected example length is fixed because we're
                  supposed to produce the shortest nonmatching string
                  possible. *)
               Alcotest.(check int) "example length"
                 (String.length expected_example)
                 (String.length example);
               (* This check may fail when the implementation changes since
                  we don't guarantee that a particular example will be
                  produced. *)
               Alcotest.(check string) "example"
                 expected_example
                 example;
    )

let test_exhaustiveness_full = test_exhaustiveness Full
let test_exhaustiveness_prefix = test_exhaustiveness Prefix

let tests _env = [
  test_match_full "a*" "" true;
  test_match_full "a*" "a" true;
  test_match_full "a*" "aa" true;
  test_match_full "a*" "ab" false;
  test_match_full "a+" "" false;
  test_match_full "a+" "a" true;
  test_match_full "a+" "aa" true;
  test_match_full "a+" "ab" false;
  test_match_full "a?" "" true;
  test_match_full "a?" "a" true;
  test_match_full "a?" "b" false;
  test_match_full "a|b" "a" true;
  test_match_full "a|b" "b" true;
  test_match_full "a|b" "c" false;
  test_match_full "a|b" "" false;
  test_match_full "a|b" "aa" false;
  test_match_full "a|a" "a" true;
  test_match_full "|" "" true;
  test_match_full "|" "a" false;
  test_match_full "[a-z]" "x" true;
  test_match_full "[a-z]" "X" false;
  test_match_full "[^a-z]" "x" false;
  test_match_full "[^a-z]" "X" true;
  test_match_full "[]" "a" false;
  test_match_full "[]" "" false;
  test_match_full "[^]" "a" true;
  test_match_full "[^]" "b" true;
  test_match_full "." "a" true;
  test_match_full "." "b" true;
  test_match_full ~name:"syntax"
    {|a\ b? [^c-de]+ ([a-f] | ! ) * |} "a bx,%!a!!def" true;

  test_match_prefix "a*" "" true;
  test_match_prefix "a*" "a" true;
  test_match_prefix "a*" "aa" true;
  test_match_prefix "a*" "ab" true;
  test_match_prefix "a+" "" false;
  test_match_prefix "a+" "a" true;
  test_match_prefix "a+" "aa" true;
  test_match_prefix "a+" "ab" true;
  test_match_prefix "a+" "bb" false;
  test_match_prefix "a?" "" true;
  test_match_prefix "a?" "a" true;
  test_match_prefix "a?" "b" true;
  test_match_prefix "a|b" "a" true;
  test_match_prefix "a|b" "b" true;
  test_match_prefix "a|b" "c" false;
  test_match_prefix "a|b" "" false;
  test_match_prefix "a|b" "aa" true;
  test_match_prefix "a|a" "a" true;
  test_match_prefix "|" "" true;
  test_match_prefix "|" "a" true;
  test_match_prefix "[a-z]" "x" true;
  test_match_prefix "[a-z]" "X" false;
  test_match_prefix "[^a-z]" "x" false;
  test_match_prefix "[^a-z]" "X" true;
  test_match_prefix "[]" "a" false;
  test_match_prefix "[]" "" false;
  test_match_prefix "[^]" "a" true;
  test_match_prefix "[^]" "b" true;
  test_match_prefix "." "a" true;
  test_match_prefix "." "b" true;

  test_shortest_match "a*" "aab" (Some "");
  test_longest_match "a*" "aab" (Some "aa");
  test_shortest_match "a*b" "aab" (Some "aab");
  test_longest_match "a*b" "aab" (Some "aab");

  test_exhaustiveness_full ".*" (Ok ());
  test_exhaustiveness_full "([a-z] | [^a-z])*" (Ok ());
  test_exhaustiveness_full "a" (Error "");
  test_exhaustiveness_full "a?" (Error "\000");
  test_exhaustiveness_full "[^a]?" (Error "a");
  test_exhaustiveness_full "." (Error "");
  test_exhaustiveness_full ".? | ...+" (Error "\000\000");
  test_exhaustiveness_full ".? | [^h]. | .[^i] | ...+" (Error "hi");
  test_exhaustiveness_full "(..)*" (Error "\000");
  test_exhaustiveness_full
    ~name:"nice graphs"
    ". | (..)* | (...)*" (Error "\000\000\000\000\000");

  test_exhaustiveness_prefix ".*" (Ok ());
  test_exhaustiveness_prefix ".*$" (Ok ());
  test_exhaustiveness_prefix "([a-z] | [^a-z])*$" (Ok ());
  test_exhaustiveness_prefix "a" (Error "");
  test_exhaustiveness_prefix "a?" (Ok ());
  test_exhaustiveness_prefix "a?$" (Error "\000");
  test_exhaustiveness_prefix "[^a]?" (Ok ());
  test_exhaustiveness_prefix "[^a]?$" (Error "a");
  test_exhaustiveness_prefix "." (Error "");
  test_exhaustiveness_prefix ".? | ...+" (Ok ());
  test_exhaustiveness_prefix "(.?|...+)$" (Error "\000\000");
  test_exhaustiveness_prefix ".? | [^h]. | .[^i] | ...+" (Ok ());
  test_exhaustiveness_prefix "(.? | [^h]. | .[^i]) $ | ...+" (Error "hi");
  test_exhaustiveness_prefix "(..)*" (Ok ());
  test_exhaustiveness_prefix "(..)*$" (Error "\000");
  test_exhaustiveness_prefix
    ~name:"nice graphs"
    "(. | (..)* | (...)*) $" (Error "\000\000\000\000\000")
]

(* Entry point of the test executable *)
let () =
  Testo.interpret_argv
    ~project_name:"exhausteve"
    tests

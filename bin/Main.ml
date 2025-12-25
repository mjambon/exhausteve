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
  print_endline (Regexp.show re)

let () = main ()

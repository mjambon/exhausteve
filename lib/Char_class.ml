(* Character classes as they appear in the regexp tree

   Our automata use a partition of the byte alphabet into character classes
   of type Char_partitition.char_class which are character classes
   plus a unique identifier.
*)

open Printf

module CC = Set.Make (Char)

type t = CC.t

let is_empty = CC.is_empty

let add = CC.add
let singleton = CC.singleton

let range a b =
  let c = ref CC.empty in
  for i = Char.code a to Char.code b do
    c := CC.add (Char.chr i) !c
  done;
  !c

let union = CC.union
let inter = CC.inter
let diff = CC.diff

let any = range '\000' '\255'
let empty = CC.empty
let alpha = union (range 'a' 'z') (range 'A' 'Z')
let digit = range '0' '9'

let mem = CC.mem
let elements = CC.elements
let of_list = CC.of_list
let choose_opt = CC.choose_opt
let fold = CC.fold
let iter = CC.iter

let elements_as_ranges cc =
  let rec loop ranges first last chars =
    match chars with
    | [] ->
        List.rev ((first, last) :: ranges)
    | c :: chars ->
        (* Either extend the ongoing range or close it and add it to
           the accumulator *)
        if Char.code c = Char.code last + 1 then
          loop ranges first c chars
        else
          loop ((first, last) :: ranges) c c chars
  in
  (* Get the set of characters in lexicographic order, then identify
     consecutive ranges by scanning the list from left to right *)
  match elements cc with
  | first :: chars -> loop [] first first chars
  | [] -> []

let show_char c = sprintf "%C" c

let show_range (first, last) =
  if first = last then
    show_char first
  else if Char.code last = Char.code first + 1 then
    sprintf "%s, %s" (show_char first) (show_char last)
  else
    sprintf "%s-%s" (show_char first) (show_char last)

let show cc =
  cc
  |> elements_as_ranges
  |> List.map show_range
  |> String.concat ", "

let pp fmt cc =
  Format.pp_print_string fmt (show cc)

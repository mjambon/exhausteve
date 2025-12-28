(** Map a character to a unique character class. *)

open Printf

type symbol_id = int

type symbol = {
  id: symbol_id;
  chars: Char_class.t;
}

type t = {
  (* Array of character classes whose ID is the position in the array *)
  partition: symbol array;
  (* Array of length 256 mapping a char to its character class *)
  bytes: symbol array;
}

let length p = Array.length p.partition

let alphabet p = Array.to_list p.partition

let assoc p c = p.bytes.(Char.code c)

let partition overlapping_char_classes =
  let input_ar = Array.of_list overlapping_char_classes in
  let subsets = Hashtbl.create 10 in
  let id_counter = ref 0 in
  let new_id () =
    let res = !id_counter in
    incr id_counter;
    res
  in
  (* For each character, build the list of character classes it belongs to
     (identified by their position in the input list) *)
  let bytes_map =
    Array.init 256 (fun i ->
      let char = Char.chr i in
      let memberships = ref [] in
      for j = Array.length input_ar - 1 downto 0 do
        if Char_class.mem char input_ar.(j) then
          memberships := j :: !memberships
      done;
      let key = !memberships in
      (match Hashtbl.find_opt subsets key with
       | None ->
           Hashtbl.add subsets key { id = new_id ();
                                     chars = Char_class.singleton char }
       | Some { id; chars } ->
           Hashtbl.replace subsets key { id;
                                         chars = Char_class.add char chars });
      key
    )
  in
  (* Finalize the subsets, order them by their assigned numeric ID *)
  let partition =
    let final_character_classes =
      Hashtbl.fold (fun _key cc ccs -> cc :: ccs) subsets []
    in
    let ar =
      List.sort (fun a b -> Int.compare a.id b.id) final_character_classes
      |> Array.of_list
    in
    Array.iteri (fun i x -> assert (x.id = i)) ar;
    ar
  in
  (* Create the map from byte to character class *)
  let bytes =
    Array.map (fun membership_key ->
      try Hashtbl.find subsets membership_key
      with Not_found -> assert false
    ) bytes_map
  in
  {
    partition;
    bytes;
  }

module Symbol = struct
  type t = symbol
  let compare a b = Int.compare a.id b.id
  let equal a b = a.id = b.id
  let hash a = a.id

  let show_id id =
    sprintf "C%i" id

  let show x =
    sprintf "%s {%s}" (show_id x.id) (Char_class.show x.chars)
end

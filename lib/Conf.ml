(** Global options *)

type matching_mode =
  | Full (** the pattern must match the whole input *)
  | Prefix (** the pattern must match a prefix of the input *)

type t = {
  matching_mode: matching_mode;
}

let default = {
  matching_mode = Full;
}

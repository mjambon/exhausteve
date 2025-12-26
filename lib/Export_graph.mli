(**
   Export automata to the DOT graph format for visualization with Graphviz
*)

(** Print a graph in the DOT format to a file *)
val export_nfa_to_file : string -> NFA.state array -> unit

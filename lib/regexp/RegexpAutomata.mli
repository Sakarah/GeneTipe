(** This module describes the non deterministic finite automata (NDFA) representation of a regular expression.
    This representation allow the evalutation of the regexp on a given text and can be directly constructed from the tree representation of {!RegexpTree}. *)

(** This type represents a regular expression in its NDFA form. *)
type t;;

(** Convert the regexp tree into a NDFA *)
val from_tree : RegexpTree.t -> t

(** Return true if the string matches the regexp represented by the automata. *)
val is_matching : t -> string -> bool

(** Return all the substring positions that are matching the regexp.
    The substring positions are given using the start included end excluded convention.
    Moreover we always match the longest contiguous possible string *)
val matching_substrings : t -> string -> (int*int) list

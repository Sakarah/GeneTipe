(** RegexpParser is a module intended to transform a string into a regexp tree. *)

(** Exception raised when a parsing error occur *)
exception Error of string

(** Parse the given string into a regular expression tree. *)
val parse : string -> RegexpTree.t

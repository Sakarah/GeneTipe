(** RegexpTree is the module describing the tree representation of the regular expressions.
    A regexp tree does not allow any kind of evaluation but is useful for all the gentic operations.
    That is why we use this representation for representing individuals in {!RegexpDna} that we can then translate to finite automata for evaluation (with the {!RegexpAutomata} module). *)

(** RegexpTree.t is the type of a regular expression tree. *)
type t =
    | Concatenation of t*t (** A matching string must match first and then second *)
    | Alternative of t*t (** A matching string must match first or second *)
    | Optional of t (** A matching string can match the child or the empty string *)
    | OneOrMore of t (** A matching string must match the child at least once and maybe more times *)
    | ZeroOrMore of t (** A matching string can match the child an unspecified number of times (maybe never) *)
    | ExactChar of char (** A matching string is the specified character and only that character (length of 1) *)
    | CharRange of (char*char) list (** A matching string is a single character in the specified ranges *)
    | AnyChar (** This match any one character long string *)

(** Retrurn the depth of the regexp tree *)
val depth : t -> int

(** Give a string representation of the regular expression.
    The format of the returned string is very similar to the one described in {!Str.regexp} except that '(', ')' and '|' do not need a \ to be  considered as operators and will be escaped when used litterally. *)
val to_string : t -> string

(** Print the regexp (See {!to_string}) *)
val print : Format.formatter -> t -> unit

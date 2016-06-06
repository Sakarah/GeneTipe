(** MathParser is a module intended to transform a string into a float -> float function
    The accepted strings are composed of classical functions (like ln, cos, ...) and standard operations
    with the infixed notation (ex: 1+x). The variable is the letter x.
    Note that there is no operator precedance management so parentheses are mandatory.
    For example 2*x+1 raise an error and should be rewritten as (2*x)+1 *)

exception Error of string

(** Parse the given stream into a callable float function.
    Stop as soon as a full function is completed. *)
val parse_stream : char Stream.t -> float -> float

(** Parse the given string into a callable float function.
    Raise an error if the string is too long. *)
val parse : string -> float -> float
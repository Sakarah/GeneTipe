(** MathParser is a module intended to transform a string into a float function
    The accepted strings are composed of classical functions (like ln, cos, ...) and standard operations
    with the infixed notation (ex: 1+x). The accepted variables must be given to the parse function (usually you just need x and you can use the simple parse1Var function).
    Note that there is no operator precedance management so parentheses are mandatory.
    For example 2*x+1 raise an error and should be rewritten as (2*x)+1 *)

exception Error of string

(** Parse the given string into a callable float function.
    The var argument represent the accepted variables from the input.
    The parameters passed to the generated function must be in the same order.
    Raise an error if the string is too long. *)
val parse : var_array:string array -> string -> float array -> float

(** Parse the given stream into a callable float function.
    See MathParser.parse for the meaning of var.
    Stop as soon as a full function is completed. *)
val parse_stream : var_array:string array -> char Stream.t -> float array -> float

(** Parse the given string into a callable single variable function.
    The variable is named "x". *)
val parse_x : string -> float -> float

(** Parse the given string into a binary float function (float -> float -> float).
    The variables are named "x" and "y". *)
val parse_xy : string -> float -> float -> float

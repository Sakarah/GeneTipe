type t =
    | Concatenation of t*t
    | Alternative of t*t
    | Optional of t
    | OneOrMore of t
    | ZeroOrMore of t
    | ExactChar of char
    | CharRange of (char*char) list
    | AnyChar
;;

(* == Evaluation and printing == *)
let rec depth = function
    | Concatenation (child1,child2) | Alternative (child1,child2) -> 1+ (max (depth child1) (depth child2))
    | Optional child | OneOrMore child | ZeroOrMore child -> 1+(depth child)
    | ExactChar _ | CharRange _ | AnyChar -> 0
;;

type bracket_level =
    | NoBracket
    | InsideConcat
    | InsideRepeat
;;
let to_string dna =
    (* Add brackets to the given string when necessary*)
    let opt_bracket str include_inside_concat = function
        | NoBracket -> str
        | InsideConcat when include_inside_concat -> "("^str^")"
        | InsideConcat -> str
        | InsideRepeat -> "("^str^")"
    in

    (* Return a string representing the given character escaping it if necessary *)
    let quoted_char ch = match ch with
        | '\\' | '.' | '*' | '+' | '?' | '[' | ']' | '(' | ')' | '|' -> "\\"^(String.make 1 ch)
        | _ -> String.make 1 ch
    in

    (* Return a string representation of the given character ranges *)
    let rec ranges_to_string = function
        | [] -> ""
        | (startCh,endCh)::t when startCh=endCh -> (quoted_char startCh)^(ranges_to_string t)
        | (startCh,endCh)::t -> (quoted_char startCh)^"-"^(quoted_char endCh)^(ranges_to_string t)
    in

    (* Real recursive implementation of the to_string function *)
    let rec to_string_impl bracket = function
        | Concatenation (child1,child2) -> opt_bracket ((to_string_impl InsideConcat child1)^(to_string_impl InsideConcat child2)) false bracket
        | Alternative (child1,child2) -> opt_bracket ((to_string_impl NoBracket child1)^"|"^(to_string_impl NoBracket child2)) true bracket
        | Optional child -> (to_string_impl InsideRepeat child)^"?"
        | OneOrMore child -> (to_string_impl InsideRepeat child)^"+"
        | ZeroOrMore child -> (to_string_impl InsideRepeat child)^"*"
        | ExactChar ch -> quoted_char ch
        | CharRange l -> "["^(ranges_to_string l)^"]"
        | AnyChar -> "."
    in
    to_string_impl NoBracket dna
;;

let print ppf dna = Format.fprintf ppf "%s" (to_string dna);;

exception Error of string;;

let unary_primitives = 
  [ ("ln", fun x -> log x);
    ("exp", fun x -> exp x);
    ("sqrt", fun x -> sqrt x);
    ("abs", fun x -> abs_float x);
    ("cos", fun x -> cos x);
    ("sin", fun x -> sin x);
    ("tan", fun x -> tan x);
    ("acos", fun x -> acos x);
    ("asin", fun x -> asin x);
    ("atan", fun x -> atan x);
    ("cosh", fun x -> cosh x);
    ("sinh", fun x -> sinh x);
    ("tanh", fun x -> tanh x) ]
;;

let binary_primitives = 
  [ ("+", fun a b -> a +. b);
    ("-", fun a b -> a -. b);
    ("*", fun a b -> a *. b);
    ("/", fun a b -> a /. b);
    ("^", fun a b -> a ** b) ]
;;

let lexer = Genlex.make_lexer ["(";")";"x"];;

let parse_tokens stream =
    let rec parse_expr () = 
        let first_part = parse_atom () in
        parse_remainder first_part
    and parse_atom () =
        match Stream.next stream with
            | Genlex.Float const -> (function x -> const)
            | Genlex.Int const -> (function x -> float_of_int const)
            | Genlex.Kwd "x" -> (function x -> x)
            | Genlex.Kwd "(" -> 
                let result = parse_expr () in
                let closing_bracket = Stream.next stream in
                if closing_bracket <> Genlex.Kwd ")" then raise (Error "Not matching parenthesis")
                else result
            | Genlex.Ident f -> 
            (
                try
                    let func = List.assoc f unary_primitives in
                    let inside = parse_atom () in
                    (function x -> func (inside x))
                with Not_found -> raise (Error (f ^ " is not a valid unary function"))
            )
            | _ -> raise (Error "Unrecognized token")
    and parse_remainder first_part =
        match Stream.peek stream with
            | None | Some Genlex.Kwd ")" -> first_part
            | _ ->
                match Stream.next stream with
                    | Genlex.Ident operator ->
                    (
                        try
                            let op = List.assoc operator binary_primitives in
                            let second_part = parse_atom () in
                            (function x -> op (first_part x) (second_part x))
                        with Not_found -> (raise (Error (operator ^ " is not a valid operator")))
                    )
                    | _ -> raise (Error "Expected operator")
    in
    try parse_expr ()
    with Stream.Failure -> raise (Error "Unexpected end of stream")
;;

let parse_stream input = parse_tokens (lexer input);;

let parse str =
    let stream = lexer (Stream.of_string str) in
    let result = parse_tokens stream in
    if Stream.peek stream <> None then raise (Error "Too much characters in the string")
    else result
;;
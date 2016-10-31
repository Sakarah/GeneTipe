exception Error of string;;

let parse str =
    let stream = Stream.of_string str in

    (* This function parses an character range considering that the '[' is already extracted. *)
    let rec parse_range ?(litteral=false) range_list =
        match Stream.next stream with
            | ']' when not litteral -> RegexpTree.CharRange range_list
            | '\\' when not litteral -> parse_range ~litteral:true range_list
            | start when Stream.peek stream = Some '-' -> Stream.junk stream; parse_range ((start,Stream.next stream)::range_list)
            | single_char -> parse_range ((single_char,single_char)::range_list)
    in

    (* This function parses an entire regular expression from the stream *)
    let rec parse_regexp () =
        parse_alternative (parse_concat_sequence ())

    (* Parse a single concatenation sequence (this should stop at the first '|' or ')' found) *)
    and parse_concat_sequence () =
        parse_concat_remainder (parse_token ())

    (* Parse a single token defined as the base unit of concatenation *)
    and parse_token () =
        match Stream.next stream with
            | '(' -> parse_regexp ()
            | ')' | ']' | '|' | '?' | '+' | '*' -> raise (Error "Unexpected operator")
            | '[' -> parse_range []
            | '.' -> RegexpTree.AnyChar
            | '\\' -> RegexpTree.ExactChar (Stream.next stream)
            | c -> RegexpTree.ExactChar c

    (* Continue the parsing of a concatenation sequence knowing that a first_part token was already extracted for this sequence *)
    and parse_concat_remainder first_part =
        match Stream.peek stream with
            | None -> first_part
            | Some ')' -> first_part
            | Some '|' -> first_part
            | Some '?' -> Stream.junk stream; parse_concat_remainder (RegexpTree.Optional first_part)
            | Some '+' -> Stream.junk stream; parse_concat_remainder (RegexpTree.OneOrMore first_part)
            | Some '*' -> Stream.junk stream; parse_concat_remainder (RegexpTree.ZeroOrMore first_part)
            | _ -> RegexpTree.Concatenation (first_part, parse_concat_sequence ())

    (* Continue the parsing of an alternative after the extraction of a concatenation sequence *)
    and parse_alternative first_part =
        match Stream.peek stream with
            | None -> first_part
            | Some ')' -> Stream.junk stream; first_part
            | Some '|' -> Stream.junk stream; RegexpTree.Alternative (first_part, parse_regexp ())
            | _ -> raise (Error "A concatenation sequence have not been totally extracted before parsing alternatives")
    in

    let result = parse_regexp () in
    if Stream.peek stream <> None then raise (Error "Too much characters in the string")
    else result
;;

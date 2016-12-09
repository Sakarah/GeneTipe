type range_event =
    | Begin of char
    | End of char
;;

(** Simplifies a range by merging all the adjacent ranges. *)
let simplify_range range =
    (* We use here a sweep line algorithm with begin range and end of range events. *)
    let rec range_to_events = function
        | [] -> []
        | (b,e)::t -> (Begin b)::(End e)::(range_to_events t)
    in
    let rec events_to_range depth begin_char = function
        | [] -> []
        | (Begin c)::t when depth = 0 -> events_to_range 1 c t
        | (Begin c)::t -> events_to_range (depth+1) begin_char t
        | (End c)::t when depth = 1 -> (begin_char,c)::(events_to_range 0 ' ' t)
        | (End c)::t -> events_to_range (depth-1) begin_char t
    in
    let compare_events ev1 ev2 =
        match ev1,ev2 with
            | Begin b, End e -> if int_of_char b <= int_of_char e + 1 then -1 else 1
            | End e, Begin b -> if int_of_char b <= int_of_char e + 1 then 1 else -1
            | Begin b1, Begin b2 -> compare b1 b2
            | End e1, End e2 -> compare e1 e2
    in

    let events = range_to_events range in
    let sorted_events = List.sort compare_events events in
    events_to_range 0 ' ' sorted_events
;;

(** Simplifies a regexp tree by grouping character alternatives in a single char range.
    Ex : a|b -> [ab], a|. -> ., [ac]|[A-Z] -> [acA-Z], etc *)
let rec simplify_tree = function
    | RegexpTree.Concatenation (a,b) -> RegexpTree.Concatenation (simplify_tree a, simplify_tree b)
    | RegexpTree.Alternative (a,b) ->
        let newA = simplify_tree a in
        let newB = simplify_tree b in
        ( match newA,newB with
            | RegexpTree.AnyChar,_ -> RegexpTree.AnyChar
            | _,RegexpTree.AnyChar -> RegexpTree.AnyChar
            | RegexpTree.CharRange r1, RegexpTree.CharRange r2 -> RegexpTree.CharRange (simplify_range (r1@r2))
            | RegexpTree.CharRange r, RegexpTree.ExactChar c | RegexpTree.ExactChar c, RegexpTree.CharRange r ->
                RegexpTree.CharRange (simplify_range ((c,c)::r))
            | RegexpTree.ExactChar c1, RegexpTree.ExactChar c2 -> RegexpTree.CharRange (simplify_range [(c1,c1);(c2,c2)])
            | _ -> RegexpTree.Alternative (newA,newB)
        )
    | RegexpTree.Optional child -> RegexpTree.Optional (simplify_tree child)
    | RegexpTree.OneOrMore child -> RegexpTree.OneOrMore (simplify_tree child)
    | RegexpTree.ZeroOrMore child -> RegexpTree.ZeroOrMore (simplify_tree child)
    | RegexpTree.CharRange range -> RegexpTree.CharRange (simplify_range range)
    | other -> other
;;

let group_chars_simplification _ = simplify_tree;;

let () =
    RegexpSearch.Simplification.register "group_chars" group_chars_simplification
;;

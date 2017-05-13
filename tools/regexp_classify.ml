let () =
    let regexp = ref "" in
    let substr = ref false in
    let limit_pos = ref (-1) in
    let limit_neg = ref (-1) in
    let char_pos = ref "+" in
    let char_neg = ref "-" in

    let spec_list =
    [
        ("--filter", Arg.Unit (function () -> char_pos := ""; limit_neg := 0), " Remove all the non matching strings instead of adding +/- (Same as -l 0 -C '')");
        ("-f", Arg.Unit (function () -> char_pos := ""; limit_neg := 0), " Shorthand for --filter");
        ("--substr", Arg.Set substr, " Print all the substring that are matching for each string. All other options are ignored if this one is selected");
        ("-s", Arg.Set substr, " Shorthand for --substr");
        ("--limit-pos", Arg.Set_int limit_pos, "l Limit the number of matching strings printed to l");
        ("-L", Arg.Set_int limit_pos, "l Shorthand for --limit-pos");
        ("--limit-neg", Arg.Set_int limit_neg, "l Limit the number of non-matching strings printed to l");
        ("-l", Arg.Set_int limit_neg, "l Shorthand for --limit-neg");
        ("--char-pos", Arg.Set_string char_pos, "c Set the character (or character group) prepended to matching strings");
        ("-C", Arg.Set_string char_pos, "l Shorthand for --char-pos");
        ("--char-neg", Arg.Set_string char_neg, "c Set the character (or character group) prepended to non-matching strings");
        ("-c", Arg.Set_string char_neg, "l Shorthand for --char-neg");
    ]
    in

    let usage_msg =
        "Classify input string according to the given regexp.\n\
        By default, it prepends a '+' to the matching strings and a '-' to the non-matching ones.\n\
        The program treats each line as an independent string.\n\
        It only stops when reaching end of file (by reading EOF).\n\
        Usage : regexp-classify [options] regexp\n\
        \n\
        Options available:"
    in

    Arg.parse (Arg.align spec_list) (fun reg -> regexp := reg) usage_msg;
    if !regexp = "" then raise (Arg.Bad "No regular expression given");

    let regexp_tree = RegexpParser.parse !regexp in
    let regexp_automata = RegexpAutomata.from_tree regexp_tree in
    try
        while !limit_pos != 0 || !limit_neg != 0 do
            let str = read_line () in
            if !substr then
            (
                let submatch = RegexpAutomata.matching_substrings regexp_automata str in
                let print_match (first,last) =
                    Printf.printf "%s\n" (String.sub str first (last-first))
                in
                List.iter print_match submatch
            )
            else
            (
                let matching = RegexpAutomata.is_matching regexp_automata str in
                if matching && !limit_pos != 0 then
                (
                    decr limit_pos;
                    Printf.printf "%s\n" (!char_pos^str)
                )
                else if !limit_neg != 0 then
                (
                    decr limit_neg;
                    Printf.printf "%s\n" (!char_neg^str)
                )
            )
        done
    with End_of_file -> ()
;;

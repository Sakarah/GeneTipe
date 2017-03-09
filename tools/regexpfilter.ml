let () =
    let regexp = ref "" in
    let substr = ref false in

    let spec_list =
    [
        ("--substr", Arg.Set substr, " Print all the substring that are matching for each string");
        ("-s", Arg.Set substr, " Shorthand for --substr");
    ]
    in

    let usage_msg =
        "Prints all the strings of the input that are matching the regular expression on the command line.\n\
        The program treats each line as an independent string.\n\
        It only stops when reaching end of file (by reading EOF).\n\
        Usage : regexpfilter [options] regexp\n\
        \n\
        Options available:"
    in

    Arg.parse spec_list (fun reg -> regexp := reg) usage_msg;
    if !regexp = "" then raise (Arg.Bad "No regular expression given");

    let regexp_tree = RegexpParser.parse !regexp in
    let regexp_automata = RegexpAutomata.from_tree regexp_tree in
    try
        while true do
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
                if RegexpAutomata.is_matching regexp_automata str then
                    Printf.printf "%s\n" str
            )
        done
    with End_of_file -> ()
;;

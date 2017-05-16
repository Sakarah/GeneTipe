let () =
    let regexp = ref "" in

    let usage_msg =
        "Evaluate the given regexp on the examples and counter examples given as input.\n\
        Each line begining with a + is an example that should be matched by the regexp.\n\
        Each line begining with a - is a counter-example that should not be matched by the regexp.\n\
        Usage : regexp-eval regexp\n\
        \n\
        Options available:"
    in

    Arg.parse [] (fun reg -> regexp := reg) usage_msg;
    if !regexp = "" then raise (Arg.Bad "No regular expression given");

    let regexp_tree = RegexpParser.parse !regexp in
    let regexp_automata = RegexpAutomata.from_tree regexp_tree in

    let true_positive = ref 0 in
    let true_negative = ref 0 in
    let false_positive = ref 0 in
    let false_negative = ref 0 in

    let remove_first_char str = String.sub str 1 (String.length str - 1) in

    try
        while true do
            let str = read_line () in
            if String.length str >= 2 then
            (
                let matching = RegexpAutomata.is_matching regexp_automata (remove_first_char str) in
                if matching then
                (
                    if str.[0] = '+' then incr true_positive
                    else if str.[0] = '-' then incr false_positive
                )
                else
                (
                    if str.[0] = '+' then incr false_negative
                    else if str.[0] = '-' then incr true_negative
                )
            )
        done
    with End_of_file ->
        Printf.printf "%d correct guess(es) (%d true positive and %d true negative)\n" (!true_positive + !true_negative) !true_positive !true_negative;
        Printf.printf "%d incorrect guess(es) (%d false positive and %d false negative)\n" (!false_positive + !false_negative) !false_positive !false_negative;
;;

let () =
    let nb_str = ref 100 in
    let alphabet = ref "abcdefghijklmnopqrstuvwxyz" in
    let min_length = ref 1 in
    let max_length = ref 20 in

    let spec_list =
    [
        ("--len-range", Arg.Tuple [Arg.Set_int min_length ; Arg.Set_int max_length], " Set the range of length of the generated strings (default is [1,20])");
        ("-l", Arg.Tuple [Arg.Set_int min_length ; Arg.Set_int max_length], " Shorthand for --len-range");
        ("--rand", Arg.Int (function r -> Random.init r), " Set the random seed");
        ("-r", Arg.Int (function r -> Random.init r), " Shorthand for --rand");
        ("--nb-str", Arg.Set_int nb_str, " Set the number of strings to generate (default is 100)");
        ("-n", Arg.Set_int nb_str, " Shorthand for --nb-str")
    ]
    in

    let usage_msg =
        "Generate a totally random list of strings taking chars form the given alphabet (or lower-case ASCII by default).\n\
        Running the program with the same parameters will give the same result. You have to change the seed to create another dataset.\n\
        Usage : randstr [options] alphabet\n\
        \n\
        Options available:"
    in

    Arg.parse (Arg.align spec_list) (fun alph -> alphabet := alph) usage_msg;

    for i = 1 to !nb_str do
        let size = !min_length + Random.int (!max_length - !min_length) in
        let str = Bytes.create size in
        for i = 0 to size-1 do
            Bytes.set str i !alphabet.[Random.int (String.length !alphabet)]
        done;
        Printf.printf "%s\n" (Bytes.to_string str)
    done;
;;

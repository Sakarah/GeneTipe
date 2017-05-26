let create_from_example replacement_pattern (ex,_) ~pop_frac =
    let example_index = int_of_float (float_of_int (Array.length ex) *. pop_frac) in
    let example = ex.(example_index) in

    let rec repl_char c = function
        | [] -> RegexpTree.ExactChar c
        | (proba,tree,automata)::_ when RegexpAutomata.is_matching automata (String.make 1 c) && Random.float 1. < proba -> tree
        | _::t -> repl_char c t
    in

    let rec make_tree i j =
        if i = j then repl_char example.[i] replacement_pattern
        else
            let k = (i+j)/2 in
            RegexpTree.Concatenation (make_tree i k, make_tree (k+1) j)
    in

    make_tree 0 (String.length example - 1)
;;

let build_create_from_ex json =
    let open Yojson.Basic.Util in
    let read_repl_pattern pattern_json =
        let proba = pattern_json |> member "proba" |> to_float in
        let regexp = pattern_json |> member "regexp" |> to_string in
        let regexp_tree = RegexpParser.parse regexp in
        let regexp_automata = RegexpAutomata.from_tree regexp_tree in
        (proba, regexp_tree, regexp_automata)
    in
    let repl_pattern = json |> member "replacement_patterns" |> convert_each read_repl_pattern in
    create_from_example repl_pattern
;;

let () =
    RegexpSearchHooks.Creation.register "from_example" build_create_from_ex;
;;

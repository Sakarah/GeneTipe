type t = string array * string array;;

let remove_first_char str = String.sub str 1 (String.length str - 1);;

let read () =
    let positive_examples = ref [] in
    let negative_examples = ref [] in

    (try
        while true do
            let str = read_line () in
            if String.length str >= 2 then
            (
                if str.[0] = '+' then
                    positive_examples := (remove_first_char str)::(!positive_examples)
                else if str.[0] = '-' then
                    negative_examples := (remove_first_char str)::(!negative_examples)
            )
        done
    with End_of_file -> ());

    (Array.of_list !positive_examples, Array.of_list !negative_examples)
;;

let remove_matching (ex,cex) regexp_tree =
    let regexp_automata = RegexpAutomata.from_tree regexp_tree in

    let filter_matching_in_array arr =
        let res_list = ref [] in
        for i = 0 to Array.length arr - 1 do
            if not (RegexpAutomata.is_matching regexp_automata arr.(i)) then
                res_list := arr.(i)::(!res_list)
        done;
        Array.of_list !res_list
    in

    (filter_matching_in_array ex, filter_matching_in_array cex)
;;

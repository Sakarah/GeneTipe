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

type t = string array * string array;;

let id x = x;;

let read_string_array () =
    let nb_str = Scanf.sscanf (read_line ()) "%d" id in
    let str_array = Array.make nb_str "" in
    for i = 0 to nb_str-1 do
        str_array.(i) <- read_line ()
    done;
    str_array
;;

let read () =
    let positive_examples = read_string_array () in
    let negative_examples = read_string_array () in
    (positive_examples, negative_examples)
;;

let plot _ _ = ();;

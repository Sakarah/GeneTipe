type t = string array * string array;;

let id x = x;;

let read_string_array () =
    let nb_str = Scanf.scanf "%d\n" id in
    let str_array = Array.make nb_str "" in
    for i = 0 to nb_str-1 do
        str_array.(i) <- Scanf.scanf "%s\n" id
    done;
    str_array
;;

let read () = (read_string_array (), read_string_array ());;

let plot _ _ = ();;

let from_proba_list l =
    let rand = Random.float 1. in
    let rec get cumul = function
        | [] -> failwith "Empty list"
        | [(_,elem)] -> elem
        | (proba,elem)::_ when proba +. cumul > rand -> elem
        | (proba,_)::t -> get (proba+.cumul) t
    in
    get 0. l
;;

let uniform_float (lower_bound,greater_bound) =
    (Random.float (greater_bound-.lower_bound)) +. lower_bound
;;

let pregenerated_normal_var = ref None;;
let normal_float ~mean ~deviation =
    match !pregenerated_normal_var with
        | Some v ->
            pregenerated_normal_var := None;
            (deviation *. v) +. mean
        | None ->
            let x = ref 0. in
            let y = ref 0. in
            let s = ref 0. in
            while !s = 0. || !s >= 1. do
                x := uniform_float (0.,1.);
                y := uniform_float (0.,1.);
                s := (!x *. !x) +. (!y *. !y);
            done;
            let mul = sqrt(-2. *. (log !s) /. !s) in
            pregenerated_normal_var := Some (!x*.mul);
            deviation *. (!y *. mul) +. mean
;;

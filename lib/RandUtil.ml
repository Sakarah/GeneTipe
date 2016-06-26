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

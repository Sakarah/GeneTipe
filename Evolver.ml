let init_population ~size ~max_depth =
    Array.init size (function _ -> (None, Dna.create_random ~max_depth))
;;

let fitness points dna =
    try 
        let n = Array.length points in
        let difference = ref 0. in
        for i = 0 to n-1 do
            let x,y = points.(i) in
            let evaluation = Dna.eval x dna in
            if evaluation = None then raise IllFormed 
            else difference := !difference +. ( evaluation -. y ) ** 2.
        done;
        !difference
    with 
        IllFormed -> None
;;

let tournament initialPopulation =
    initialPopulation (* Gabzcr *)
;;

let reproduce initialPopulation =
    initialPopulation (* Sakarah *)
;;

let evolve initialPopulation ~generations =
    initialPopulation (* Gabzcr ? *)
;;

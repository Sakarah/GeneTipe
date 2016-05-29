let init_population ~size ~max_depth =
    Array.init size (function _ -> (None, Dna.create_random ~max_depth))
;;

let fitness points dna =
    let n = Array.length points in
    let difference = ref 0. in
    for i = 0 to n-1 do
        let x,y = points.(i) in
        difference := !difference +. ( (Dna.eval x dna) -. y ) ** 2.
    done;
    !difference
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

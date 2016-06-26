let diff2 _ points dna =
    let n = Array.length points in
    let difference = ref 0. in
    for i = 0 to n-1 do
        let x,y = points.(i) in
        let evaluation = Dna.eval dna x in
        difference := !difference +. ( evaluation -. y ) ** 2.
    done;
    if classify_float !difference = FP_nan then 0. (* nan is not equal itself... *)
    else 1. /. (1. +. !difference)
;;

let () =
    Plugin.Fitness.register "diff2" diff2
;;

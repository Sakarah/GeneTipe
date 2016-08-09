module M =
struct
    type individual = FunctionDna.t;;
    
    module TargetData =
    struct
        type t = (float*float) array;;
        
        let read () = 
            let nb_points = Scanf.scanf "%d\n" (function n -> n) in
            let points = Array.make nb_points (0.,0.) in
            for i = 0 to nb_points-1 do
                points.(i) <- Scanf.scanf "%f %f\n" (fun x y -> (x,y))
            done;
            points
        ;;
    end;;
    
    let fitness points dna =
        let n = Array.length points in
        let difference = ref 0. in
        for i = 0 to n-1 do
            let x,y = points.(i) in
            let evaluation = FunctionDna.eval dna x in
            difference := !difference +. ( evaluation -. y ) ** 2.
        done;
        if classify_float !difference = FP_nan then 0. (* nan is not equal itself... *)
        else 1. /. (1. +. !difference)
    ;;
end

let () =
    SymbolicRegression.Fitness.register "squared_diff" (function _ -> (module M))
;;

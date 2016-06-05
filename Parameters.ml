(** This module contains some default parameters for random generation
    Feel free to tweak them and experiment *)

(** Default random generation params *)
let rand_gen_params =
{ Dna.
    fill_proba = 0.5 ;
    bin_op =
        [| (0.25, "+", fun a b -> a +. b);
           (0.20, "-", fun a b -> a -. b);
           (0.25, "*", fun a b -> a *. b);
           (0.20, "/", fun a b -> a /. b);
           (0.10, "^", fun a b -> a ** b) |] ;
    bin_proba = 0.80 ;

    un_op =
        [| (0.2, "cos", fun a -> cos a);
           (0.2, "sin", fun a -> sin a);
           (0.2, "tan", fun a -> tan a);
           (0.2, "ln", fun a -> log a);
           (0.2, "exp", fun a -> exp a) |];
    un_proba = 0.10 ;

    const_range = (-5.,5.) ;
    const_proba = 0.5 ;
    var_proba = 0.5
}

let evolution_params max_depth random_gen_params =
{ Evolver.
    max_depth = max_depth ;
    random_gen_params = random_gen_params ;
    growth_factor = 2.0 ;
    mutation_ratio = 0.1
}

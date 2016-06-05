let best_individual population =
    population.(0) (* Gabzcr ? *)
;;

let average_fitness population =
    0. (* Gabzcr ? *)
;;

let genetic_diversity population =
    0. (* How to measure that ?? *)
;;

let print_stats population =
    () (* Gabzcr ? *)
;;

let print_population =
    Array.iter (function (fitness, dna) -> Printf.printf "%.5f ~ " fitness; Dna.print Format.std_formatter dna; print_newline ())
;;

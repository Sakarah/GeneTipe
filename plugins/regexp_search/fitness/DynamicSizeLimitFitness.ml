(** This fitness function is the same as MultiobjectiveFitness except it gives a null fitness value to all individuals bigger and not better than previous encountered ones with a dynamic size limit.
    It uses internally the MultiobjectiveFitness plugin and accept the same parameters.
    It is compatible with a static size threshold and is intended to prevent bloat. *)
let build_dynamic_size_limit_fitness json =
    let open Yojson.Basic.Util in
    let init_size_limit = json |> member "initial_size_limit" |> to_int in

    let module MultiobjectiveFitness = (val RegexpSearchHooks.Fitness.get "multiobjective" json) in

    (module struct
        (** The fitness contains Evaluated with the real fitness value if the individual is small enough and Rejected if it is not. *)
        type t =
            | Rejected
            | Evaluated of MultiobjectiveFitness.t
        ;;

        type individual = RegexpTree.t
        type target_data = ExampleList.t

        let to_float = function
            | Rejected -> 0.
            | Evaluated fit -> MultiobjectiveFitness.to_float fit
        ;;

        let to_string = function
            | Rejected -> "Above dynamic size limit"
            | Evaluated fit -> MultiobjectiveFitness.to_string fit
        ;;

        let compare x y = Pervasives.compare (to_float x) (to_float y);;

        let best_fitness = ref 0.;;
        let size_limit = ref init_size_limit;;

        let compute examples regexp =
            let fitness = MultiobjectiveFitness.compute examples regexp in
            let float_fitness = MultiobjectiveFitness.to_float fitness in
            let size = RegexpTree.size regexp in
            if float_fitness > !best_fitness then
            (
                best_fitness := float_fitness;
                size_limit := max !size_limit size
            );
            if size > !size_limit then Rejected
            else Evaluated fitness
        ;;
    end : EvolParams.Fitness with type individual = RegexpTree.t and type target_data = ExampleList.t)
;;

let () =
    RegexpSearchHooks.Fitness.register "dynamic_size_limit" build_dynamic_size_limit_fitness
;;

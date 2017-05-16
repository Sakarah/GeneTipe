exception Error of string;;
let load filename =
    try
        Dynlink.loadfile filename
    with Dynlink.Error error -> raise (Error (Dynlink.error_message error))
;;


module type HookType =
sig
    type t
end;;

module type HookingPoint =
sig
    type t
    val register : string -> t -> unit
    val get : string -> t
end;;

module MakeHookingPoint (Type : HookType) =
struct
    type t = Type.t;;
    let registered_values = ref [];;
    let register hook_name hook =
        registered_values := (hook_name,hook)::!registered_values;
    ;;
    let get hook_name =
        try
            List.assoc hook_name !registered_values
        with Not_found -> raise (Error (hook_name^" is not registered by any loaded plugin"))
    ;;
end;;

module type GeneticHooks =
sig
    module Individual : EvolParams.Individual
    type target_data
    module Creation : HookingPoint with type t = (Yojson.Basic.json -> target_data -> pop_frac:float -> Individual.t)
    module Mutation : HookingPoint with type t = (Yojson.Basic.json -> target_data -> Individual.t -> Individual.t)
    module Crossover : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t -> Individual.t)
    module Fitness : HookingPoint with type t = (Yojson.Basic.json -> (module EvolParams.Fitness with type individual = Individual.t and type target_data = target_data))
    module Simplification : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)
end

module type SelectionMethod = functor (Fitness : EvolParams.Fitness) -> sig val f:(Fitness.t * 'i) array -> target_size:int -> (Fitness.t * 'i) array end;;
module Selection = MakeHookingPoint (struct type t = (Yojson.Basic.json -> (module SelectionMethod)) end);;

module type ParentChooserMethod = functor (Fitness : EvolParams.Fitness) -> sig val f:(Fitness.t * 'i) array -> unit -> 'i end
module ParentChooser = MakeHookingPoint (struct type t = (Yojson.Basic.json -> (module ParentChooserMethod)) end)

module RandomGen = MakeHookingPoint (struct type t = (Yojson.Basic.json -> unit -> float) end);;

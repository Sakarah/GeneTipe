exception Error of string;;
let load filename = 
    try
        Dynlink.loadfile filename
    with Dynlink.Error error -> raise (Error (Dynlink.error_message error))
;;


module type HookType =
sig
    type t (** Data type of the hook to create *)
end;;

module type HookClass =
sig
    type t
    val register : string -> t -> unit (** Register a new hook with the specified key *)
    val get : string -> t (** Get the hook corresponding to the given key *)
end;;

module MakeHookClass (Type : HookType) : (HookClass with type t = Type.t) = 
struct
    type t = Type.t;;
    let registered_values = Hashtbl.create 10;;
    let register = Hashtbl.add registered_values;;
    let get hook_name =
        try
            Hashtbl.find registered_values hook_name
        with Not_found -> raise (Error (hook_name^" is not registered by any loaded plugin"))
    ;;
end;;

module type FitnessEvaluator = 
sig
    type individual
    module TargetData : EvolParams.TargetData
    val fitness : TargetData.t -> individual -> float
end;;

module type GeneticTypeInterface =
sig
    module Individual : EvolParams.Individual
    module Creation : HookClass with type t = (Yojson.Basic.json -> pop_frac:float -> Individual.t)
    module Mutation : HookClass with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)
    module Crossover : HookClass with type t = (Yojson.Basic.json -> Individual.t -> Individual.t -> Individual.t)
    module Fitness : HookClass with type t = (Yojson.Basic.json -> (module FitnessEvaluator with type individual = Individual.t))
    module Simplification : HookClass with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)
end;;

module GeneticType = MakeHookClass (struct type t = (module GeneticTypeInterface) end);;
module RandomGen = MakeHookClass (struct type t = (Yojson.Basic.json -> unit -> float) end);;

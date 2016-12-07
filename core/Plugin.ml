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
    module Creation : HookingPoint with type t = (Yojson.Basic.json -> pop_frac:float -> Individual.t)
    module Mutation : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)
    module Crossover : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t -> Individual.t)
    module Fitness : HookingPoint with type t = (Yojson.Basic.json -> (module FitnessEvaluator with type individual = Individual.t))
    module Simplification : HookingPoint with type t = (Yojson.Basic.json -> Individual.t -> Individual.t)
end;;

module GeneticType = MakeHookingPoint (struct type t = (module GeneticTypeInterface) end);;

module type SelectionFunction = sig val f:(float * 'i) array -> target_size:int -> (float * 'i) array end;;
module Selection = MakeHookingPoint (struct type t = (Yojson.Basic.json -> (module SelectionFunction)) end);;

module type ParentChooserFunction = sig val f:(float * 'i) array -> unit -> 'i end;;
module ParentChooser = MakeHookingPoint (struct type t = (Yojson.Basic.json -> (module ParentChooserFunction)) end)

module RandomGen = MakeHookingPoint (struct type t = (Yojson.Basic.json -> unit -> float) end);;

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
    module TargetData : EvolParams.TargetData
    val fitness : TargetData.t -> Dna.t -> float
end;;

module RandomGen = MakeHookClass (struct type t = (Yojson.Basic.json -> unit -> float) end);;
module BinOp = MakeHookClass (struct type t = (Yojson.Basic.json -> float -> float -> float) end);;
module UnOp = MakeHookClass (struct type t = (Yojson.Basic.json -> float -> float) end);;
module TermNode = MakeHookClass (struct type t = (Yojson.Basic.json -> (int*(float list->string)*(float list->float->float))) end);;
module Creation = MakeHookClass (struct type t = (Yojson.Basic.json -> pop_frac:float -> Dna.t) end);;
module Mutation = MakeHookClass (struct type t = (Yojson.Basic.json -> Dna.t -> Dna.t) end);;
module Crossover = MakeHookClass (struct type t = (Yojson.Basic.json -> Dna.t -> Dna.t -> Dna.t) end);;
module Fitness = MakeHookClass (struct type t = (Yojson.Basic.json -> (module FitnessEvaluator)) end);;
module Simplification = MakeHookClass (struct type t = (Yojson.Basic.json -> Dna.t -> Dna.t) end);;

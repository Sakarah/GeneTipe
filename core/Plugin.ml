exception Error of string;;
let load filename = 
    try
        Dynlink.loadfile filename
    with Dynlink.Error error -> raise (Error (Dynlink.error_message error))
;;

module type HookType = sig
    type t
end;;

module type HookClass = sig
    type t
    val register : string -> t -> unit
    val get : string -> t
end;;

module MakeHookClass (Type : HookType) : (HookClass with type t = Type.t) = struct
    type t = Type.t;;
    let registered_values = Hashtbl.create 10;;
    let register = Hashtbl.add registered_values;;
    let get hook_name =
        try
            Hashtbl.find registered_values hook_name
        with Not_found -> raise (Error (hook_name^" is not registered by any loaded plugin"))
    ;;
end;;


module RandomGen = MakeHookClass (struct type t = (Yojson.Basic.json -> unit -> float) end);;
module BinOp = MakeHookClass (struct type t = (Yojson.Basic.json -> float -> float -> float) end);;
module UnOp = MakeHookClass (struct type t = (Yojson.Basic.json -> float -> float) end);;
module Creation = MakeHookClass (struct type t = (Yojson.Basic.json -> max_depth:int -> Dna.t) end);;
module Mutation = MakeHookClass (struct type t = (Yojson.Basic.json -> max_depth:int -> Dna.t -> Dna.t) end);;
module Crossover = MakeHookClass (struct type t = (Yojson.Basic.json -> Dna.t -> Dna.t -> Dna.t) end);;
module Fitness = MakeHookClass (struct type t = (Yojson.Basic.json -> (float*float) array -> Dna.t -> float) end);;
module Simplification = MakeHookClass (struct type t = (Yojson.Basic.json -> Dna.t -> Dna.t) end);;

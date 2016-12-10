module Creation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> ExampleList.t -> pop_frac:float -> RegexpTree.t) end);;
module Mutation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> ExampleList.t -> RegexpTree.t -> RegexpTree.t) end);;
module Crossover = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t -> RegexpTree.t) end);;
module Fitness = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> ExampleList.t -> RegexpTree.t -> float) end);;
module Simplification = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t) end);;

let () =
    Plugin.GeneticType.register "regexp_search"
    (module struct
        module Individual = RegexpDna;;
        module TargetData = ExampleList;;
        module Creation = Creation;;
        module Mutation = Mutation;;
        module Crossover = Crossover;;
        module Fitness = Fitness;;
        module Simplification = Simplification;;
    end : Plugin.GeneticTypeInterface)
;;

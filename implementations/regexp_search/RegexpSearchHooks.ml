module Individual = RegexpDna;;
type target_data = ExampleList.t;;

module Creation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> ExampleList.t -> pop_frac:float -> RegexpTree.t) end);;
module Mutation = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> ExampleList.t -> RegexpTree.t -> RegexpTree.t) end);;
module Crossover = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t -> RegexpTree.t) end);;
module Fitness = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> ExampleList.t -> RegexpTree.t -> float) end);;
module Simplification = Plugin.MakeHookingPoint (struct type t = (Yojson.Basic.json -> RegexpTree.t -> RegexpTree.t) end);;

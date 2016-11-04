open Yojson.Basic.Util;;

let uniform_generator json =
    let min = json |> member "min" |> to_float in
    let max = json |> member "max" |> to_float in
    function () -> RandUtil.uniform_float (min,max)
;;

let () =
    Plugin.RandomGen.register "uniform" uniform_generator
;;

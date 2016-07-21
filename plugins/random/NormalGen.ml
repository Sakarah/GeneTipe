open Yojson.Basic.Util;;

let normal_generator json =
    let mean = json |> member "mean" |> to_float in
    let deviation = json |> member "deviation" |> to_float in
    function () -> RandUtil.normal_float ~mean ~deviation
;;

let () =
    Plugin.RandomGen.register "normal" normal_generator
;;
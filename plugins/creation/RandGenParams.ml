type t =
{
    bin_op : (float * string * (float -> float -> float)) array ;
    bin_proba : float ;
    un_op : (float * string * (float -> float)) array ;
    un_proba : float ;
    const_range : (float*float) ;
    const_proba : float ;
    var_proba : float
}


open Yojson.Basic.Util;;

let to_op get_method json =
    let proba = json |> member "proba" |> to_float in
    let name = json |> member "name" |> to_string in
    let op = json |> member "op" |> to_string |> get_method in
    let params = json |> member "params" in
    (proba, name, op params)
;;
let to_bin_op = to_op Plugin.BinOp.get;;
let to_un_op = to_op Plugin.UnOp.get;;

let to_range json = ( json |> member "min" |> to_number, json |> member "max" |> to_number );;

let read json =
    {
        bin_op = json |> member "bin_op" |> convert_each to_bin_op |> Array.of_list;
        bin_proba = json |> member "bin_proba" |> to_float;

        un_op = json |> member "un_op" |> convert_each to_un_op |> Array.of_list;
        un_proba = json |> member "un_proba" |> to_float;

        const_range = json |> member "const_range" |> to_range;
        const_proba = json |> member "const_proba" |> to_float;

        var_proba = json |> member "var_proba" |> to_float
    }
;;

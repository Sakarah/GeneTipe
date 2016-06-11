type randomGen =
{
    fill_proba: float;
    bin_op:(float * string * (float -> float -> float)) array ;
    bin_proba:float ;
    un_op:(float * string * (float -> float)) array ;
    un_proba:float ;
    const_range:(float*float) ;
    const_proba:float ;
    var_proba:float
};;

type evolution =
{
    pop_size : int ;
    max_depth : int ;
    random_gen_params : randomGen ;
    growth_factor : float ;
    mutation_ratio : float
};;

exception Error of string;;


open Yojson.Basic.Util;;

let to_op parse_func json =
    let proba = json |> member "proba" |> to_float in
    let name = json |> member "name" |> to_string in
    let op = json |> member "fun" |> to_string |> parse_func in
    (proba,name,op)
;;
let to_bin_op = to_op MathParser.parse_xy;;
let to_un_op = to_op MathParser.parse_x;;

let to_range json = ( json |> member "min" |> to_number, json |> member "max" |> to_number );;

let to_random_gen_params json =
    {
        fill_proba = json |> member "fill_proba" |> to_float;

        bin_op = json |> member "bin_op" |> convert_each to_bin_op |> Array.of_list;
        bin_proba = json |> member "bin_proba" |> to_float;

        un_op = json |> member "un_op" |> convert_each to_un_op |> Array.of_list;
        un_proba = json |> member "un_proba" |> to_float;

        const_range = json |> member "const_range" |> to_range;
        const_proba = json |> member "const_proba" |> to_float;

        var_proba = json |> member "var_proba" |> to_float
    }
;;

let to_evolution_params json =
    {
        pop_size = json |> member "pop_size" |> to_int;
        max_depth = json |> member "max_depth" |> to_int;
        random_gen_params = json |> member "random_gen" |> to_random_gen_params;
        growth_factor = json |> member "growth_factor" |> to_number;
        mutation_ratio = json |> member "growth_factor" |> to_float
    }
;;

let read_params ?pop_size ?max_depth ~filename =
    try
        let params = Yojson.Basic.from_file filename |> to_evolution_params in
        {
            pop_size =
            ( match pop_size with
                | None -> params.pop_size
                | Some n -> n
            );
            max_depth =
            ( match max_depth with
                | None -> params.max_depth
                | Some d -> d
            );
            random_gen_params = params.random_gen_params;
            growth_factor = params.growth_factor;
            mutation_ratio = params.mutation_ratio
        }
    with Yojson.Basic.Util.Type_error (str,json) ->
        raise (Error ("Unable to load configuration from "^filename^" : "^str^" ("^(Yojson.Basic.to_string json)^")"))
;;

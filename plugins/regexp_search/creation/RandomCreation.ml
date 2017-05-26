(** This type represents the parameters for the random generation of a regular expression *)
type params =
{
    concat_proba : float ; (** Probability of using concatenation. *)
    alt_proba : float ; (** Probability of using an alternative (|) *)
    opt_proba : float ; (** Probability of using an optional node (?) *)
    plus_proba : float ; (** Probability of using a one or more node (+) *)
    star_proba : float ; (** Probability of using a zero or more node ( * ) *)
    rand_char_proba : float ; (** Probability of using a random single char from the positive exmaples *)
    predefined_proba : float ; (** Probability of using a predefined regexp *)
    predefined_list : (float*RegexpTree.t) list (** List of predefined subregexp with their associated probabilities *)
}

(** Select a random character from the positive examples of the dataset *)
let get_random_char (examples,_) =
    let rand_example = examples.(Random.int (Array.length examples)) in
    rand_example.[Random.int (String.length rand_example)]
;;

(** Randomly generate a new individual *)
let create_random ~fill gen_params data ~max_depth =
    let rec create depth =
        (* If max_depth is reached, then we have to put a terminal node (ie random char or perdefined) *)
        if depth = 0 then
        (
            let p = Random.float (gen_params.rand_char_proba +. gen_params.predefined_proba) in
            if p < gen_params.rand_char_proba then
                RegexpTree.ExactChar (get_random_char data)
            else
                RandUtil.from_proba_list gen_params.predefined_list
        )
        else
        (
            let p_concat = gen_params.concat_proba in
            let p_alt = p_concat +. gen_params.alt_proba in
            let p_opt = p_alt +. gen_params.opt_proba in
            let p_plus = p_opt +. gen_params.plus_proba in
            let p_star = p_plus +. gen_params.star_proba in
            let p_rand_char = p_star +. gen_params.rand_char_proba in

            (* If we are in the fill mode, we must avoid choosing a terminal node before depth = 0 *)
            let p = Random.float (if fill then p_star else 1.) in

            if p < p_concat then
                RegexpTree.Concatenation (create (depth-1), create (depth-1))
            else if p < p_alt then
                RegexpTree.Alternative (create (depth-1), create (depth-1))
            else if p < p_opt then
                RegexpTree.Optional (create (depth-1))
            else if p < p_plus then
                RegexpTree.OneOrMore (create (depth-1))
            else if p < p_star then
                RegexpTree.ZeroOrMore (create (depth-1))
            else if p < p_rand_char then
                RegexpTree.ExactChar (get_random_char data)
            else
                RandUtil.from_proba_list gen_params.predefined_list
        )
    in
    create max_depth
;;

(** Randomly generate a new individual who has a depth below max_depth *)
let create_random_grow = create_random ~fill:false;;

(** Randomly generate a new individual who has a depth of exactly max_depth for all branches *)
let create_random_fill = create_random ~fill:true;;

(** Distribute the max_depth value between min and max across the population *)
let ramped creation_fun min max ~pop_frac = creation_fun ~max_depth:(min+(int_of_float (pop_frac *. float_of_int (max-min))))

(** Read the random generation parameters from the json tree given *)
let read_params json =
    let open Yojson.Basic.Util in
    let to_predefined json =
        let proba = json |> member "proba" |> to_float in
        let regexp = json |> member "regexp" |> to_string in
        (proba, RegexpParser.parse regexp)
    in
    {
        concat_proba = json |> member "concat_proba" |> to_float;
        alt_proba = json |> member "alt_proba" |> to_float;
        opt_proba = json |> member "opt_proba" |> to_float;
        plus_proba = json |> member "plus_proba" |> to_float;
        star_proba = json |> member "star_proba" |> to_float;
        rand_char_proba = json |> member "rand_char_proba" |> to_float;
        predefined_proba = json |> member "predefined_proba" |> to_float;
        predefined_list = json |> member "predefined_list" |> convert_each to_predefined
    }
;;

let make_pattern creation_fun json data =
    let params = read_params json in
    let open Yojson.Basic.Util in
    let min_depth = json |> member "min_init_depth" |> to_int in
    let max_depth = json |> member "max_init_depth" |> to_int in
    ramped (creation_fun params data) min_depth max_depth
;;

let grow_pattern = make_pattern create_random_grow;;
let fill_pattern = make_pattern create_random_fill;;

let () =
    RegexpSearchHooks.Creation.register "grow" grow_pattern;
    RegexpSearchHooks.Creation.register "fill" fill_pattern
;;

let () =
    let x_fuzz = ref 0. in
    let y_fuzz = ref 0.1 in

    let spec_list =
    [
        ("--x-fuzz", Arg.Set_float x_fuzz, "dist Set how far the abscissae can get from the original point (default is 0)");
        ("-x", Arg.Set_float x_fuzz, "dist Shorthand for --x-fuzz");
        ("--y-fuzz", Arg.Set_float y_fuzz, "dist Set how far the ordinates can get from the original point (default is 0.1)");
        ("-y", Arg.Set_float y_fuzz, "dist Shorthand for --y-fuzz");
        ("--rand", Arg.Int (function r -> Random.init r), "seed Set the random seed");
        ("-r", Arg.Int (function r -> Random.init r), "seed Shorthand for --rand")
    ]
    in

    let usage_msg =
        "Take a set of point as input and modify it slightly to simulate errors in measurement.\n\
        Running the program with the same parameters will give the same result. You have to change the seed to create a dataset with different modifications.\n\
        A set of point is composed by the number of sampling points on the first line and then on each line the x and y coordinates of a point separated by a space.\n\
        Usage : fuzzpts [options]\n\
        \n\
        Options available:"
    in

    Arg.parse (Arg.align spec_list) (fun _ -> raise (Arg.Bad "Unexpected argument")) usage_msg;

    let nb_points = Scanf.scanf "%d\n" (function n -> n) in
    Printf.printf "%d\n" nb_points;
    for i = 0 to nb_points-1 do
        let (x,y) = Scanf.scanf "%f %f\n" (fun x y -> (x,y)) in
        let fuzzed_x = RandUtil.uniform_float (x-.(!x_fuzz), x+.(!x_fuzz)) in
        let fuzzed_y = RandUtil.uniform_float (y-.(!y_fuzz), y+.(!y_fuzz)) in
        Printf.printf "%f %f\n" fuzzed_x fuzzed_y
    done;
;;

let () =
    let nb_points = ref 100 in
    let minX = ref 0. in
    let maxX = ref 10. in
    let minY = ref 0. in
    let maxY = ref 10. in

    let spec_list =
    [
        ("--x-range", Arg.Tuple [Arg.Set_float minX ; Arg.Set_float maxX], "Set the range of the abscissae of the generated points (default is [0,10])");
        ("-x", Arg.Tuple [Arg.Set_float minX ; Arg.Set_float maxX], "Shorthand for --x-range");
        ("--y-range", Arg.Tuple [Arg.Set_float minY ; Arg.Set_float maxY], "Set the range of the ordinates of the generated points (default is [0,10])");
        ("-y", Arg.Tuple [Arg.Set_float minY ; Arg.Set_float maxY], "Shorthand for --y-range");
        ("--rand", Arg.Int (function r -> Random.init r), "Set the random seed");
        ("-r", Arg.Int (function r -> Random.init r), "Shorthand for --rand");
        ("--nb-pts", Arg.Set_int nb_points, "Set the number of points to generate (default is 100)");
        ("-n", Arg.Set_int nb_points, "Shorthand for --nb-pts")
    ]
    in

    let usage_msg =
        "Generate a totally random set a points by linearly choosing x and y values inside the accepted range.\n" ^
        "Running the program with the same parameters will give the same result. You have to change the seed to create another dataset.\n" ^
        "The program prints the number of sampling points on the first line and then on each line the x and y coordinates of a point separated by a space.\n"^
        "Usage : randpts [options]\n\n" ^
        "Options available:"
    in

    Arg.parse spec_list (fun _ -> raise (Arg.Bad "Unexpected argument")) usage_msg;

    Printf.printf "%d\n" !nb_points;
    for point = 0 to !nb_points-1 do
        let x = RandUtil.uniform_float (!minX,!maxX) in
        let y = RandUtil.uniform_float (!minY,!maxY) in
        Printf.printf "%f %f\n" x y
    done;
;;

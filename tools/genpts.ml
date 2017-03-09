let () =
    let nb_points = ref 101 in
    let minX = ref 0. in
    let maxX = ref 10. in
    let funcStr = ref "" in

    let spec_list =
    [
        ("--range", Arg.Tuple [Arg.Set_float minX ; Arg.Set_float maxX], " Set the range of the generated points (default is [0,10])");
        ("-r", Arg.Tuple [Arg.Set_float minX ; Arg.Set_float maxX], " Shorthand for --range");
        ("--nb-pts", Arg.Set_int nb_points, " Set the number of points to generate (deafult is 101)");
        ("-n", Arg.Set_int nb_points, " Shorthand for --nb-pts")
    ]
    in

    let usage_msg =
        "Generate a set a points from the given function.\n\
        The program prints the number of sampling points on the first line and then on each line the x and y coordinates of a point separated by a space.\n\
        Usage : genpts [options] function\n\
        \n\
        Options available:"
    in

    Arg.parse (Arg.align spec_list) (fun anon -> funcStr := anon) usage_msg;

    let func = MathParser.parse_x !funcStr in

    Printf.printf "%d\n" !nb_points;
    let step = ((!maxX)-.(!minX))/.(float_of_int (!nb_points-1)) in
    for point = 0 to !nb_points-1 do
        let x = !minX +. step *. (float_of_int point) in
        let y = func x in
        Printf.printf "%f %f\n" x y
    done;
;;

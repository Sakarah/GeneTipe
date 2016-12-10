type t = (float*float) array;;

let read () =
    let nb_points = Scanf.scanf "%d\n" (function n -> n) in
    let points = Array.make nb_points (0.,0.) in
    for i = 0 to nb_points-1 do
        points.(i) <- Scanf.scanf "%f %f\n" (fun x y -> (x,y))
    done;
    points
;;

let plot points = Plot.plot ~color:Graphics.red ~link:false (Array.map fst points) (Array.map snd points)

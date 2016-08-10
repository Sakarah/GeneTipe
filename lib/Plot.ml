type graph =
{
    height : int;
    width : int;
    border : int;
    title : string;
    mutable x_min : float;
    mutable x_max : float;
    mutable y_min : float;
    mutable y_max : float;
    mutable curves : (Graphics.color * bool * float array * float array) list
};;

let init ~size ~border ~title =
    {
        height = fst size ;
        width = snd size ;
        border = border ;
        title = title ;
        x_min = infinity ;
        x_max = neg_infinity ;
        y_min = infinity ;
        y_max = neg_infinity ;
        curves = []
    }
;;

(* set_range returns the min and the max of the x array. *)
let set_range x =
    let x_min = ref x.(0) and x_max = ref x.(0) in
    let n = Array.length x in
    for i = 0 to n - 1 do
    (
        if !x_min >= x.(i) then x_min := x.(i);
        if !x_max <= x.(i) then x_max := x.(i)
    )
    done;
    !x_min, !x_max
;;


(* Plot called to plot a new set of points during the next show() *)
let plot ?(link=true) ?(color=Graphics.black) x y graphic =
    if Array.length x != Array.length y then
        failwith "Not matching arrays."
    else
    (
        (* Update graphic parameters. *)
        let x_min, x_max = set_range x in
        if graphic.x_min > x_min then graphic.x_min <- x_min;
        if graphic.x_max < x_max then graphic.x_max <- x_max;

        let y_min, y_max = set_range y in
        if graphic.y_min > y_min then graphic.y_min <- y_min;
        if graphic.y_max < y_max then graphic.y_max <- y_max;

        (* Add the current set to the graphic. *)
        graphic.curves <- (color, link, x, y)::graphic.curves
    )
;;

let draw_point x y = Graphics.fill_circle x y 3;;

let plot_fun ?link ?color ?range ?nb_pts func graphic =
    let x_min, x_max = match range with
        | None -> graphic.x_min, graphic.x_max
        | Some range -> range
    in

    let nb_pts = match nb_pts with
        | None -> graphic.width
        | Some n -> n
    in
    
    let step = (x_max-.x_min)/.(float_of_int (nb_pts-1)) in
    let x_array = Array.init nb_pts (fun n -> x_min +. step *. (float_of_int n)) in
    let y_array = Array.map func x_array in

    plot ?link ?color x_array y_array graphic
;;

let show graphic =
    Graphics.close_graph ();
    Graphics.open_graph (" "^string_of_int (graphic.width+2*graphic.border) ^"x"^string_of_int (graphic.height+2*graphic.border));
    Graphics.set_window_title graphic.title;
    let show_one_curve (color, link, x, y) =
        Graphics.set_color color;
        Graphics.set_line_width 2;
        let n = Array.length x in
        for i = 0 to n - 1 do
        (
            let xi = graphic.border + int_of_float ( (x.(i) -. graphic.x_min) *. (float_of_int graphic.width) /. (graphic.x_max -. graphic.x_min) ) in
            let yi = graphic.border + int_of_float ( (y.(i) -. graphic.y_min) *. (float_of_int graphic.height) /. (graphic.y_max -. graphic.y_min) ) in
            if link then
            (
                if i = 0 then Graphics.moveto xi yi
                else Graphics.lineto xi yi
            )
            else draw_point xi yi
        )
        done;
    in
    List.iter show_one_curve graphic.curves;
;;

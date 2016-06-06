open Graphics;;

type graph =
{
	mutable height : int;
	mutable width : int;
	mutable x_min : float;
	mutable x_max : float;
	mutable y_min : float;
	mutable y_max : float;
	mutable nb_curves : int;
	mutable curves : (int * bool * float array * float array) list
};;


(* Predefined colors. *)

let colors = [| Graphics.blue ; Graphics.red ; Graphics.green ; Graphics.magenta |];;

(** Init returns an empty graphic *)
let init h w =
	{
		height = h ;
		width = w ;
		x_min = infinity ;
		x_max = neg_infinity ;
		y_min = infinity ;
		y_max = neg_infinity ;
		nb_curves = 0 ;
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

let plot ?(link=true) ?(color=0) x y graphic =
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
		graphic.nb_curves <- graphic.nb_curves + 1;
		let color = ref color in
		if !color = 0 then color := colors.( graphic.nb_curves - 1 mod Array.length colors );
		graphic.curves <- (!color, link, x, y) :: graphic.curves
	)
;;

let draw_point x y = Graphics.fill_circle x y 3
;;

let show graphic =
	Graphics.open_graph (" "^string_of_int (graphic.width+50) ^"x"^string_of_int (graphic.height+50));
	let show_one_curve (color, link, x, y) =
		Graphics.set_color color;
		Graphics.set_line_width 2;
		moveto (25 + int_of_float x.(0)) (25 + int_of_float y.(0));
		let n = Array.length x in
		for i = 0 to n - 1 do
		(
			let xi = 25 + int_of_float ( x.(i) *. (float_of_int graphic.height) /. (graphic.x_max -. graphic.x_min) ) in
			let yi = 25 + int_of_float ( y.(i) *. (float_of_int graphic.height) /. (graphic.y_max -. graphic.y_min) ) in
			if link then lineto xi yi
			else ( moveto xi yi;	draw_point xi yi )
		)
		done;
	in
	List.iter (fun curve -> show_one_curve curve) graphic.curves;
;;


(*

** Example of some code. 

let () =
(
let graphic = init 500 500 in
let x = Array.make 10 0. in
let y = Array.make 10 0. in
let z = Array.make 10 0. in
let w = Array.make 10 0. in
for i = 0 to 9 do
	x.(i) <- float_of_int (i) ;
	y.(i) <- float_of_int (i*i);
	z.(i) <- float_of_int (i);
	w.(i) <- log((float_of_int i)+.1.)
done;
plot ~link:false x y graphic ;
plot x z graphic;
plot x w graphic;
show graphic;
let x = read_int () in print_int x
)
;;

*)
(** The type graph conatins the information needed to display the required set of points, 
	such as the min and the max of each coordinates, the size of the window, 
	and the set of points as a list. *)

type graph

(** Creates a new graph with default arguments: 
	-> window size 500 x 500 *)

val init : int -> int -> graph

(** Adds a curve to an existing graphic. *)

val plot : ?link:bool -> ?color:int -> float array -> float array -> graph -> unit 

(** Displays the graphic. *)

val show : graph -> unit 

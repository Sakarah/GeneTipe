(** The type graph conatins the information needed to display the required set of points, 
    such as the min and the max of each coordinates, the size of the window, 
    and the set of points as a list.
    Due to some limitiations of the standard Graphics module you only can draw one graph at a time. *)

type graph

(** Creates a new graph with default arguments: 
    -> window size 500 x 500 *)
val init : size:(int * int) -> border:int -> title:string -> graph

(** Adds a curve to an existing graphic. *)
val plot : ?link:bool -> ?color:int -> float array -> float array -> graph -> unit 

(** Add a function to an existing graphic by computing nb_pts points linearly.
    If the range is unspecified, keep the previous graphic range. *)
val plot_fun : ?link:bool -> ?color:int -> ?range:(float*float) -> nb_pts:int -> (float -> float) -> graph -> unit

(** Displays the graphic. *)
val show : graph -> unit 

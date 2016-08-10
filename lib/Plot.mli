(** Plot provides a way to simply visualize data on screen for viewing results.
    It basically can plot any set of points or any [float->float] function.
    Due to some limitiations of the standard Graphics module you only can draw one graph at a time. *)

(** The type graph conatins the information needed to display the required set of points, 
    such as the min and the max of each coordinates, the size of the window, 
    and the set of points as a list. *)
type graph

(** Creates a new empty graph. 
    @param size Size of the window
    @param border Size of the blank displayed on the border
    @param title Title of the window *)
val init : size:(int * int) -> border:int -> title:string -> graph

(** Adds a new set of points to an existing graph.
    @param link Specify if the plotted points have to be linked to each other or not (default is true)
    @param color Specify the color of the points (default is black) *)
val plot : ?link:bool -> ?color:int -> float array -> float array -> graph -> unit 

(** Plot a function to an existing graphic.
    @param range Range of abscissae to compute for the function. Computed points are taken linearly in this range. If unspecified, keep the previous graphic range.
    @param nb_pts Number of points to compute. For low value the function showed can be highly inaccurate.*)
val plot_fun : ?link:bool -> ?color:int -> ?range:(float*float) -> nb_pts:int -> (float -> float) -> graph -> unit

(** Displays the graphic. *)
val show : graph -> unit 

(** Module for using array iterator functions with parallel speedup if available *)
(** Be careful that these function do not guarantee that the results are ordered in the same order than the input. *)

(** Similar to {!Array.iter} *)
val iter : ('a -> unit) -> 'a array -> unit

(** Similar to {!Array.iteri} *)
val iteri : (int -> 'a -> unit) -> 'a array -> unit

(** Similar to {!Array.map} *)
val map : ('a -> 'b) -> 'a array -> 'b array

(** Similar to {!Array.mapi} *)
val mapi : (int -> 'a -> 'b) -> 'a array -> 'b array

(** Similar to {!Array.fold_right} except the return type must be the same than the array type *)
val fold : ('a -> 'a -> 'a) -> 'a array -> 'a -> 'a

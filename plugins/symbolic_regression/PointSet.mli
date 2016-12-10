(** This module implements the {!EvolParams.TargetData} interface for an array of float points. *)

(** Type of a point array *)
type t = (float*float) array;;

(** Read points from the input. The first number read is the number of points in the dataset.
    This function waits until all the required points are given. *)
val read : unit -> t

(** Plots the points of the dataset on the given graph *)
val plot : t -> Plot.graph -> unit

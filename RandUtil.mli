(** RandUtil contains utility function around random generation *)

(** Return a random element from the list given according to the associated probabilities *)
val from_proba_list : (float*'a) list -> 'a

(** Generate a uniform random float value in specified range *)
val uniform_float : float*float -> float

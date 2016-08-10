(** RandUtil contains utility functions around random generation *)

(** Return a random element from the list given according to the associated probabilities *)
val from_proba_list : (float*'a) list -> 'a

(** Generate a uniform random float value in specified range *)
val uniform_float : float*float -> float

(** Generate a float value following a normal distribution using the Marsaglia polar method *)
val normal_float : mean:float -> deviation:float -> float
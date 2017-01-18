(** Parameters is the module where we define the datatypes of the parameters of the genetic algorithm.
    The module also provides a function to read them from a JSON file. *)

exception Error of string

(** This type represents the parameters for random generation of an individual *)
type randomGen =
{
    fill_proba : float; (** Probability of the full method beeing selected for generation (probability of the grow method is 1. -. fill_proba) *)
    bin_op : (float * string * (float -> float -> float)) array ; (** Array of all binary operations with their associated probability knowing that a binary node have been selected *)
    bin_proba : float ; (* probability of completing a node in a function tree with a binary operator *)
    un_op : (float * string * (float -> float)) array ; (** Array of all unary operations with their associated probability knowing that a unary node have been selected *)
    un_proba : float ; (* probability of completing a node in a function tree with a unary operator *)
    const_range : (float*float) ; (** Range in which constants are randomly taken *)
    const_proba : float ; (** Probability of choosing a constant. *)
    var_proba : float (** Probability of choosing a variable. The sum of the probabilities must be equal to 1 *)
}

(** This type represents the parameters of a genetic selection process *)
type evolution =
{
    pop_size : int ; (** Number of individuals in the population *)
    max_depth : int ; (** Maximum depth in the Dna tree of an individual *)
    random_gen_params : randomGen ; (** Random generation parameters *)
    growth_factor : float ; (** Multiplication factor of the population after a reproduction phase *)
    mutation_ratio : float (** Ratio of the mutations in the reproduction phase. When not choosing mutation, a crossover is performed. *)
}

(** Read the parameters from the specified file.
    Optional pop_size and max_depth override the parameters in the file *)
val read_params : ?pop_size:int -> ?max_depth:int -> filename:string -> evolution

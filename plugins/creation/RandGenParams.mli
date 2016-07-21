(** This module defines the type of the random generation parameters and give a function to read them from a file *)

(** This type represents the parameters for random generation of an individual *)
type t =
{
    bin_op : (float * string * (float -> float -> float)) array ; (** Array of all binary operations with their associated probability knowing that a binary node have been selected *)
    bin_proba : float ; (** Probability of choosing a binary node *)
    un_op : (float * string * (float -> float)) array ; (** Array of all unary operations with their associated probability knowing that an unary node have been selected *)
    un_proba : float ; (** Probability of choosing an unary node *)
    const_generator : unit -> float ; (** Function called for generating a random constant *)
    const_proba : float ; (** Probability of choosing a constant. *)
    var_proba : float (** Probability of choosing a variable. The sum of the probabilities must be equal to 1 *)
}

(** Read the random generation parameters from the json tree given *)
val read : Yojson.Basic.json -> t

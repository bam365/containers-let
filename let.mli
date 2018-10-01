(**
 * This module provides Let_syntax - style modules for 
 * Jane Street's ppx_let
 *
 * e.g. I want to use ppx_let and CCList to make a cross
 * product of two lists:
 *     let cross_product xs ys = 
 *         let module Let_syntax = Let.List in
 *         let%bind x = xs in
 *         let%bind y = ys in
 *         [(x, y)]
 *)

open Container_monad


module Let_syntax : sig 
    (** 
     * Approximate interface for Let_syntax. Good enough to get
     * most jobs done
     *)
    module type S = sig
        type 'a t
        val return: 'a -> 'a t
        val map: ('a -> 'b) -> 'a t -> 'b t
        val bind: 'a t -> f:('a -> 'b t) -> 'b t
        val both: 'a t -> 'b t -> ('a * 'b) t
        (** TODO There is some RHS stuff that could be included here *)
    end
end


module Make(M: ContainerMonad): Let_syntax.S with type 'a t := 'a M.t

(** 
 * Some conveniece Let_syntax modules for common monads from containers
 *)
module Opt: Let_syntax.S with type 'a t := 'a CCOpt.t
module List: Let_syntax.S with type 'a t := 'a CCList.t
module Array: Let_syntax.S with type 'a t := 'a array 


module Result: sig
    (**
     * Make a Let_syntax module out of a CCResult.t given an error type
     * e.g. let module Let_syntax = Let.Result.Make(struct type err = int
     *)
    module Make(M: sig type err end): 
        Let_syntax.S with type 'a t := 'a CCResult_monad.Type(M).t

    module String: Let_syntax.S with type 'a t := 'a CCResult_monad.String.t
end

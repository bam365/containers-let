(**
 * This module helps link together containers with ocaml-monadic, which
 * uses a PPX to allow you to do bind-style let
 *
 * e.g. I want to use ocaml-monadic and CCList to make a cross
 * product of two lists:
 *
 * let cross_product xs ys =
 *     let open Monadic.List in
 *     let%bind x = xs in
 *     let%bind y = ys in
 *     [(x, y)]
 *)

open Container_monad

module type S = sig
    type 'a t
    val return : 'a -> 'a t
    val map: ('a -> 'b) -> 'a t -> 'b t
    val bind: 'a t -> ('a -> 'b t) -> 'b t
end

module Make(M: ContainerMonad): S with type 'a t := 'a M.t 

module Opt: S with type 'a t := 'a CCOpt.t
module List: S with type 'a t := 'a CCList.t
module Array: S with type 'a t := 'a array


module Result: sig
    module Make(M: sig type err end): S with type 'a t := 'a CCResult_monad.Type(M).t

    module String: S with type 'a t := 'a CCResult_monad.String.t
end

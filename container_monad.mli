(** 
 * The interfaces for various modules in containers seem to
 * be a bit inconsistent, but this signature seems to capture
 * a valid monad from all of the ones that I looked at
 *)
module type ContainerMonad = sig
    type 'a t
    val return : 'a -> 'a t
    val map : ('a -> 'b) -> 'a t -> 'b t
    val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
end


(**
 * CCArray doesn't conform to ContainerMonad, it doesn't
 * include return, so we provide a module here that does
 * conform to that interface (we just trivially implement
 * return)
 *)
module CCArray_monad : sig
    type 'a t = 'a CCArray.t
    include ContainerMonad with type 'a t := 'a t
end


(**
 * CCResult is only monadic if the error type variable is
 * bound, so we provide some helpers to create CCResult
 * monads given some error type
 *)
module CCResult_monad : sig
    module type Intf = sig
        type err
    end

    module type S = sig
        type err
        type 'a t = ('a, err) CCResult.t
        include ContainerMonad with type 'a t := 'a t
    end

    (**
     * NOTE: This is only necessary to work around some of 
     * the artificial limitations of destructive substitution 
     * (can only substitute types with syntactically identical
     * parameters). Those limitations were fixed in OCaml 4.06,
     * so if we ever introduced a dependency to 4.06, we could
     * remove this
     *)
    module Type(M: sig type err end): sig
        type 'a t = ('a, M.err) CCResult.t
    end

    (**
     * You provide an error type err, and this functor creates a 
     * ContainerMonad for ('a, err) CCResult.t,
     *
     * e.g. if you wanted to use integers for error codes for your
     * results, you could create a monad for that like so:
     *      module Res_monad = CCResult_monad.Make(struct type err = int end)
     *)
    module Make(M: Intf): S with type err := M.err 

    (**
     * String could be a common error type to use here, so we 
     * might as well provide a convenience module for using
     * ('a, string) CCResult.t
     *)
    module String: S with type err := string 
end

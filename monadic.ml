open Container_monad

module Monadic_core = struct
    module type S = sig
        type 'a t
        val return : 'a -> 'a t
        val map: ('a -> 'b) -> 'a t -> 'b t
        val bind: 'a t -> ('a -> 'b t) -> 'b t
    end

    module Make(M: ContainerMonad): S with type 'a t := 'a M.t = struct
        let return v = M.return v
        let map f t = M.map f t
        let bind v f = M.(v >>= f)
    end

    module Opt = Make(CCOpt)
    module List = Make(CCList)
    module Array = Make(CCArray_monad)
end


include Monadic_core


module Result = struct
    module Make(N: sig type err end) =
        Monadic_core.Make(struct
            include CCResult_monad.Make(N)
        end)

    module String = Monadic_core.Make(CCResult_monad.String)
end

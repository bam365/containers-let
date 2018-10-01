open Container_monad

module Let_core = struct
    module Let_syntax = struct 
        module type S = sig
            type 'a t
            val return: 'a -> 'a t
            val map: ('a -> 'b) -> 'a t -> 'b t
            val bind: 'a t -> f:('a -> 'b t) -> 'b t
            val both: 'a t -> 'b t -> ('a * 'b) t
        end
    end


    module Make(M: ContainerMonad): 
        Let_syntax.S with type 'a t := 'a M.t 
    = struct
        let return v = M.return v

        let map f v = M.map f v

        let bind v ~f = M.(v >>= f)

        let both x y = 
            bind x ~f:(fun x' -> 
                bind y ~f:(fun y' -> 
                    return (x', y')))
    end


    module Opt = Make(CCOpt)
    module List = Make(CCList)
    module Array = Make(CCArray_monad)
end


include Let_core


module Result = struct
    module Make(N: sig type err end) =
        Let_core.Make(struct
            include CCResult_monad.Make(N)
        end)

    module String = Let_core.Make(CCResult_monad.String)
end

module type ContainerMonad = sig
    type 'a t
    val return : 'a -> 'a t
    val map : ('a -> 'b) -> 'a t -> 'b t
    val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
end


module CCArray_monad = struct
    type 'a t = 'a CCArray.t

    let return v = [| v |]

    let map f v = CCArray.map f v

    let (>>=) v f = CCArray.flat_map f v
end


module CCResult_monad = struct
    module type Intf = sig
        type err
    end


    module type S = sig
        type err
        type 'a t = ('a, err) CCResult.t
        include ContainerMonad with type 'a t := 'a t
    end


    module Type(M: sig type err end): sig
        type 'a t = ('a, M.err) CCResult.t
    end = struct
        type 'a t = ('a, M.err) CCResult.t
    end


    module Make(M: Intf): S 
        with type err := M.err 
    = struct
        type 'a t = ('a, M.err) CCResult.t

        let return v = CCResult.return v

        let map f v = CCResult.map f v

        let (>>=) v f = CCResult.flat_map f v
    end


    module String = Make(struct type err = string end)
end

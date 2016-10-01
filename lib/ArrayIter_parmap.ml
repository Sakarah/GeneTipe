(** This is the implementation of ArrayIter when Parmap is available *)

let chunksize = 10;;

let iter func a = Parmap.pariter ~chunksize func (Parmap.A a);;
let iteri func a = Parmap.pariteri ~chunksize func (Parmap.A a);;
let map func a = Parmap.array_parmap ~chunksize func a;;
let mapi func a = Parmap.array_parmapi ~chunksize func a;;
let fold func a init = Parmap.parfold ~chunksize func (Parmap.A a) init func;;

(** Selection method that randomly picks a parent without using the fitness information. *)
module UniformParentChooserFunction =
struct
    let f population () =
        let pop_size = Array.length population in
        snd population.(Random.int pop_size)
    ;;
end

let () =
    Plugin.ParentChooser.register "uniform" (function _ -> (module UniformParentChooserFunction))
;;


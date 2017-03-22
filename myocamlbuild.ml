open Ocamlbuild_plugin

let parmap = ref false;;

let () = dispatch (function
    | Before_options ->
        Options.use_ocamlfind := true;
        Options.make_links := false;

    | After_options ->
        (try
            ignore (Findlib.query "parmap");
            Printf.printf "Parmap parallelization enabled.\n";
            tag_any ["package(parmap)"];
            parmap := true
        with Findlib.Findlib_error _ ->
            Printf.printf "Parallelization unavailable (Parmap is not installed on your system).\n")

    | After_rules ->
        rule "genetipe: ArrayIter implementation selection"
            ~deps:["core/ArrayIter_parmap.ml";"core/ArrayIter_vanilla.ml"]
            ~prod:"core/ArrayIter.ml"
            ( fun _ _ ->
                let file = if !parmap then "core/ArrayIter_parmap.ml" else "core/ArrayIter_vanilla.ml" in
                cp file "core/ArrayIter.ml"
            );

        pflag ["ocaml";"ocamldep"] "searchdir" (function path -> S [A "-I"; P path]);
        pflag ["ocaml";"doc"] "searchdir" (function path -> S [A "-I"; P path]);
        pflag ["ocaml";"compile"] "searchdir" (function path -> S [A "-I"; P path]);

        ocaml_lib ~dir:"core" ~tag_name:"use_genetipe" "core/GeneTipe";
        ocaml_lib ~dir:"lib" ~tag_name:"use_randutil" "lib/RandUtil";
        ocaml_lib ~dir:"lib/regexp" ~tag_name:"use_regexp" "lib/regexp/Regexp";
        ocaml_lib ~dir:"lib/math" ~tag_name:"use_mathutil" "lib/math/MathUtil";

    | _ -> ()
);;

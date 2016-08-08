REQ_PACKAGES = "graphics,yojson,dynlink,str"
INCLUDE_DIR = "lib"
OCAMLBUILD = ocamlbuild -use-ocamlfind -Is $(INCLUDE_DIR) -pkgs $(REQ_PACKAGES) -tags linkall

genetipe:
	cd .. && $(OCAMLBUILD) core/genetipe.native
	mv ../genetipe.native ../genetipe

.PHONY: genetipe

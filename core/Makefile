REQ_PACKAGES = "graphics,yojson,dynlink"
INCLUDE_DIR = "lib"
OCAMLBUILD = ocamlbuild -Is $(INCLUDE_DIR) -pkgs $(REQ_PACKAGES)

genetipe:
	cd .. && $(OCAMLBUILD) core/genetipe.native
	mv ../genetipe.native ../genetipe

.PHONY: genetipe

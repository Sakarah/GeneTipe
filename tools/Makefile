TOOLS = genpts
REQ_PACKAGES = ""
INCLUDE_DIR = "lib"
OCAMLBUILD = ocamlbuild -Is $(INCLUDE_DIR) -pkgs $(REQ_PACKAGES)

all: $(TOOLS)

$(TOOLS): %:
	cd .. && $(OCAMLBUILD) tools/$@.native
	mv ../$@.native ../$@

.PHONY: all $(TOOLS)

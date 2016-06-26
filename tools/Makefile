TOOLS = genpts
INCLUDE_DIR = "lib"
OCAMLBUILD = ocamlbuild -Is $(INCLUDE_DIR)

all: $(TOOLS)

$(TOOLS): %:
	cd .. && $(OCAMLBUILD) tools/$@.native
	mv ../$@.native ../$@

.PHONY: all $(TOOLS)

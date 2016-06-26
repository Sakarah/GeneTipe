PLUGINS = creation/FillGrow.cmxs crossover/TakeSubtree.cmxs fitness/DiffSquare.cmxs \
	mutation/MutateConst.cmxs mutation/RebuildSubtree.cmxs primitives/MathExpr.cmxs \
	simplification/EvalConst.cmxs
REQ_PACKAGES = "yojson"
INCLUDE_DIR = "core,lib"
OCAMLBUILD = ocamlbuild -Is $(INCLUDE_DIR) -pkgs $(REQ_PACKAGES)

all: $(PLUGINS)

$(PLUGINS): %.cmxs:
	cd .. && $(OCAMLBUILD) plugins/$@

.PHONY: all $(PLUGINS)

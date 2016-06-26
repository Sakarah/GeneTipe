PLUGINS = creation/FillGrow.cmxs crossover/TakeSubtree.cmxs fitness/DiffSquare.cmxs \
	mutation/MutateConst.cmxs mutation/RebuildSubtree.cmxs primitives/MathExpr.cmxs \
	simplification/EvalConst.cmxs

all: $(PLUGINS)

%.cmxs:
	cd .. && ocamlbuild -pkgs yojson plugins/$@

clean:
	-cd .. && ocamlbuild -clean

.PHONY: all clean

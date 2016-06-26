all: genetipe genpts plugins

genetipe:
	ocamlbuild -pkgs graphics,yojson,dynlink genetipe.native
	mv genetipe.native genetipe

genpts:
	ocamlbuild genpts.native
	mv genpts.native genpts

plugins:
	$(MAKE) -C plugins

cma:
	ocamlbuild -pkgs graphics,yojson,dynlink GeneTipe.cma

doc:
	ocamlbuild GeneTipe.docdir/index.html
	mv GeneTipe.docdir doc

debug: genetipe.debug genpts.debug

genetipe.debug:
	ocamlbuild -pkgs graphics,yojson,dynlink -cflag -g -lflag -g genetipe.byte
	mv genetipe.byte genetipe.debug

genpts.debug:
	ocamlbuild -cflag -g -lflag -g genpts.byte
	mv genpts.byte genpts.debug
    
clean:
	-ocamlbuild -clean

.PHONY: all genetipe genpts plugins cma doc debug genetipe.debug genpts.debug clean


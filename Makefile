all: genetipe genpts doc

genetipe:
	ocamlbuild -pkgs graphics,yojson genetipe.native
	mv genetipe.native genetipe

genpts:
	ocamlbuild genpts.native
	mv genpts.native genpts

cma:
	ocamlbuild -pkgs graphics,yojson GeneTipe.cma

doc:
	ocamlbuild GeneTipe.docdir/index.html
	mv GeneTipe.docdir doc

debug: genetipe.debug genpts.debug

genetipe.debug:
	ocamlbuild -pkgs graphics,yojson -cflag -g -lflag -g genetipe.byte
	mv genetipe.byte genetipe.debug

genpts.debug:
	ocamlbuild -cflag -g -lflag -g genpts.byte
	mv genpts.byte genpts.debug

clean:
	ocamlbuild -clean

.PHONY: all debug clean


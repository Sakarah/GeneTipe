OCAMLBUILD = ocamlbuild -use-ocamlfind -no-links
SUBDIRS = core plugins tools
TOOL_SYMLINK = genpts

all: build-all symlinks

build-all:
	$(OCAMLBUILD) all.otarget

$(SUBDIRS): %:
	$(OCAMLBUILD) $@/$@.otarget

symlinks: genetipe $(TOOL_SYMLINK)
genetipe:
	ln -s _build/core/genetipe.native genetipe
$(TOOL_SYMLINK): %:
	ln -s _build/tools/$@.native $@

doc:
	$(OCAMLBUILD) GeneTipe.docdir/index.html

clean:
	-rm -r _build
	-rm genetipe $(TOOL_SYMLINK)

.PHONY: all build-all $(SUBDIRS) symlinks doc clean

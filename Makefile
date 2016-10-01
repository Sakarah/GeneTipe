OCAMLBUILD = ocamlbuild -use-ocamlfind -no-links
SUBDIRS = core plugins tools
TOOL_SYMLINK = genpts randpts fuzzpts

all: configure build-all symlinks

configure: _tags lib/ArrayIter.ml
_tags: _tags_vanilla
	cp _tags_vanilla _tags
lib/ArrayIter.ml: | _tags
	@if ocamlfind query parmap; \
	then \
		echo "Parmap parallelization enabled"; \
		ln -s ArrayIter_parmap.ml lib/ArrayIter.ml; \
		echo "true: package(parmap)" >> _tags; \
	else \
		echo "Parallelization unavailable"; \
		ln -s ArrayIter_vanilla.ml lib/ArrayIter.ml; \
	fi

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
	-rm _tags
	-rm lib/ArrayIter.ml
	-rm genetipe $(TOOL_SYMLINK)

.PHONY: all configure build-all $(SUBDIRS) symlinks doc clean

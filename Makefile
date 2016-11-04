OCAMLBUILD = ocamlbuild -use-ocamlfind -no-links
SUBDIRS = core plugins tools
TOOL_SYMLINK = genpts randpts fuzzpts regexpfilter

all: configure build-all symlinks

configure: _tags lib/ArrayIter.ml
_tags: _tags_vanilla
	cp _tags_vanilla _tags
lib/ArrayIter.ml: | _tags
	@if [ $$(uname -o) = "Cygwin" ]; \
	then \
		echo "Parallelization unavailable on Windows (using Cygwin)"; \
		cp lib/ArrayIter_vanilla.ml lib/ArrayIter.ml; \
	else \
		if ocamlfind query parmap > /dev/null; \
		then \
			echo "Parmap parallelization enabled"; \
			ln -s ArrayIter_parmap.ml lib/ArrayIter.ml; \
			echo "true: package(parmap)" >> _tags; \
		else \
			echo "Parallelization unavailable (Parmap is not installed on your system)"; \
			ln -s ArrayIter_vanilla.ml lib/ArrayIter.ml; \
		fi; \
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

sanitize: clean
	@echo "Replacing tabs with 4 spaces in OCaml files"
	@for f in $$(find . -name "*.ml*"); \
	do \
		sed -i "s/\t/    /g" $$f ; \
	done
	@echo "Removing spaces at end of line"
	@for f in $$(find . -path './.git' -prune -type f -o -type f); \
	do \
		sed -i "s/ \+$$//g" $$f ; \
	done
	@echo "Ensure new line at end of file"
	@for f in $$(find . -path './.git' -prune -type f -o -type f); \
	do \
		sed -i '$$a\' $$f ; \
	done

.PHONY: all configure build-all $(SUBDIRS) symlinks doc clean sanitize

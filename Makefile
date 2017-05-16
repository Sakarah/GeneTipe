OCAMLBUILD = ocamlbuild
SUBDIRS = lib core implementations plugins tools
IMPLEMENTATION_SYMLINK = regexp-search symbolic-regression
TOOL_SYMLINK = genpts randpts fuzzpts randstr regexp-classify regexp-eval

all: build-all symlinks

build-all:
	$(OCAMLBUILD) all.otarget

$(SUBDIRS): %:
	$(OCAMLBUILD) $@/$@.otarget

symlinks: $(IMPLEMENTATION_SYMLINK) $(TOOL_SYMLINK)
$(IMPLEMENTATION_SYMLINK): %:
	ln -s _build/implementations/$(subst -,_,$@)/$(subst -,_,$@).native $@
$(TOOL_SYMLINK): %:
	ln -s _build/tools/$(subst -,_,$@).native $@

doc:
	$(OCAMLBUILD) GeneTipe.docdir/index.html

clean:
	-rm -r _build
	-rm $(IMPLEMENTATION_SYMLINK)
	-rm $(TOOL_SYMLINK)

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

.PHONY: all build-all $(SUBDIRS) symlinks doc clean sanitize

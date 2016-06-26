SUBDIRS = core plugins tools

all: $(SUBDIRS)

$(SUBDIRS): %:
	$(MAKE) -C $@

clean:
	-ocamlbuild -clean

.PHONY: all $(SUBDIRS) clean

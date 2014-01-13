#              Serene - Search App
#          Copyright (C)  2014 Heather
#

RACO=raco
RCFLAGS=--gui -v
SRCDIR=.
SRC=Serene.rkt
INSTALL   ?= install
MKDIR     ?= $(INSTALL) -d
BINDIR    ?= $(PREFIX)/bin
DESTDIR   ?=

r:	$(SRCDIR)
	cd $^ && $(RACO) exe ${RCFLAGS} $(SRC)

.PHONY: clean rebuild

rebuild: clean | r

clean:
	@echo " --- Clean binaries --- "
	rm -f Serene Serene.exe

#@echo " --- Clean temp files --- "
#find . -name '*~' -delete;
#find . -name '#*#' -delete;

install:
	$(MKDIR) $(DESTDIR)$(BINDIR)
	$(INSTALL) Serene$(EXE) $(DESTDIR)$(BINDIR)/

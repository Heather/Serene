#              Serene - Search App
#          Copyright (C)  2014 Heather
#

RACO=raco
SSFLAGS=-v
SERENEFLAGS=--gui -v
SRCDIR=.
SSRC=ss.rkt
SRC=Serene.rkt
INSTALL   ?= install
MKDIR     ?= $(INSTALL) -d
BINDIR    ?= $(PREFIX)/bin
DESTDIR   ?=

Serene:	$(SRCDIR)
	cd $^ && $(RACO) exe ${SERENEFLAGS} $(SRC)
    
ss:	$(SRCDIR)
	cd $^ && $(RACO) exe ${SSFLAGS} $(SSRC)

.PHONY: clean rebuild

rebuild: clean | Serene

clean:
	rm -f Serene Serene.exe ss ss.exe .ss

install:
	$(MKDIR) $(DESTDIR)$(BINDIR)
	$(INSTALL) Serene$(EXE) $(DESTDIR)$(BINDIR)/

.POSIX:

INSTALL ?= install
ASCIIDOC ?= asciidoc
SOURCES := luasubprocess.c liolib-copy.c
VERSION := 0.02
DISTDIR := lua-subprocess-$(VERSION)
DISTFILES := Makefile $(SOURCES) liolib-copy.h subprocess.txt luasubprocess.html

lua_package := lua
INSTALL_CMOD := $(shell pkg-config --variable=INSTALL_CMOD $(lua_package))
ifeq ($(INSTALL_CMOD),)
lua_package := lua5.1
INSTALL_CMOD := $(shell pkg-config --variable=INSTALL_CMOD $(lua_package))
endif

ifeq ($(INSTALL_CMOD),)
$(error Lua package not found)
endif

CFLAGS ?= -Wall -Wextra -pedantic -O2
LUA_CFLAGS := $(shell pkg-config --cflags --libs $(lua_package))

.PHONY: all
all: luasubprocess.so luasubprocess.html

luasubprocess.so: $(SOURCES)
	$(CC) $(CFLAGS) $(LUA_CFLAGS) -DOS_POSIX -shared -fPIC -o $@ $(SOURCES)

luasubprocess.html: subprocess.txt
	$(ASCIIDOC) $<

.PHONY: clean
clean:
	$(RM) luasubprocess.so

.PHONY: install
install: luasubprocess.so
	$(INSTALL) -m755 luasubprocess.so $(INSTALL_CMOD)/

.PHONY: uninstall
uninstall:
	$(RM) $(INSTALL_CMOD)/luasubprocess.so

.PHONY: dist
dist: $(DISTFILES)
	[ -d $(DISTDIR) ] || mkdir $(DISTDIR)
	$(INSTALL) -m644 $(DISTFILES) $(DISTDIR)/
	tar -czf $(DISTDIR).tar.gz $(DISTDIR)

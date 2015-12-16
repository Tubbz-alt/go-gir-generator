PREFIX = /usr

all: build

CURRENT_DIR = $(shell pwd)
export GOPATH = $(CURDIR):$(CURDIR)/vendor:$(CURDIR)/out

GENERATOR = out/gir-generator

build: glib-2.0 gobject-2.0 gio-2.0

generator:
	mkdir -p out/src/gir
	cd src/gir-generator && go build -o $(CURRENT_DIR)/${GENERATOR}

copyfile:
	cp -r  lib.in/gobject-2.0/*   out/src/gir/gobject-2.0
	cp -r  lib.in/gio-2.0/*       out/src/gir/gio-2.0
	cp -r  lib.in/glib-2.0/*      out/src/gir/glib-2.0

	
glib-2.0: lib.in/glib-2.0/glib.go.in lib.in/glib-2.0/config.json generator
	${GENERATOR} -o  out/src/gir/$@ $<

gobject-2.0: lib.in/gobject-2.0/gobject.go.in lib.in/gobject-2.0/config.json generator
	${GENERATOR} -o out/src/gir/$@ $<

gio-2.0:  lib.in/gio-2.0/gio.go.in lib.in/gio-2.0/config.json generator
	${GENERATOR} -o out/src/gir/$@ $<

test: copyfile
	cd out/src/gir/gobject-2.0 && go test	
	cd out/src/gir/gio-2.0 && go test	
	cd out/src/gir/glib-2.0 && go test	
	
install: copyfile
	install -d  $(DESTDIR)$(PREFIX)/share/gocode/src/gir $(DESTDIR)$(PREFIX)/bin
	cp -r  out/src/gir/*   $(DESTDIR)$(PREFIX)/share/gocode/src/gir
	cp     out/gir-generator $(DESTDIR)$(PREFIX)/bin/

clean:  
	rm -fr out 

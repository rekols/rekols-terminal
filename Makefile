VALAC = valac

PKG =   --pkg gtk+-3.0 \
	--pkg vte-2.91

SRC =   main.vala \
	src/window.vala \
	src/headerbar.vala \
	src/terminal.vala \
	src/flowbox.vala \
 	src/globals.vala \
	src/utils.vala  \
	src/dialog.vala

OPTIONS = -X -w  # Ignore gcc warnings

BIN = main

all:
	$(VALAC) $(PKG) $(SRC) $(OPTIONS) -o $(BIN)


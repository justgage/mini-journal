main:
	corebuild src/mj.native -pkgs calendar
	rm mj.native
	cp _build/src/mj.native ./mj
opam:
	opam install core calendar
install:
	cp mj ~/bin/.

main:
	corebuild src/mj.native -pkgs calendar
	mv mj.native mj
opam:
	opam install core calendar
install:
	cp mj ~/bin/.

main:
	corebuild src/timetravel.native -pkgs calendar
	corebuild src/mj.native -pkgs calendar
	rm mj.native
	cp _build/src/mj.native ./mj
	echo "Compiled sucessfully!!!"
opam:
	opam install core calendar
install:
	cp mj ~/bin/.

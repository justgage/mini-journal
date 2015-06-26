# Mini Journal (ALPHA)

Simple journaling from the command line written mostly to learn about OCaml.

# Usage:

if you want a short entry do:

```
$ mj -m "Today I Learned OCaml"
journal entry added to: /Users/you/mini-journal/default/2015-06-26-Fri.md
```

```
$ mj -n ocamlJournal -m "This will go in a different folder"
journal entry added to: /Users/you/mini-journal/ocamlJournal/2015-06-26-Fri.md
```

Running it without arguments like so:

```
$ mj
```

This will open up whatever editor is set to the `$EDITOR` enviormental variable. this will spawn vim for me.

If your editor isn't set then it will just pull it in from standard in and wait till you push `CTRL-D` (for some reason it requires it to happen twice)

Natrualy you can get help with `mj -h`

# Install 

there's an OSX binary in the main folder that you can copy to a local bin.

`make install` will put it in `~/bin` which I put in my path.

# To compile:

You must have installed:

- OCaml
- opam

install the opam packages you need with: `make opam`

then to build a native binary: `make`

to move that binary to local bin: `make install`


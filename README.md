# Mini Journal (ALPHA)

Simple journaling from the command line written mostly to learn about OCaml.

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

# Usage:

```
$ mj -n myJournalName -m "This is an entry"

```

Your journal will currently be saved to: `~/.myJournalName.md`


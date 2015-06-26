# Mini Journal (ALPHA)

Simple journaling from the command line written mostly to learn about OCaml.

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


# Mini Journal (ALPHA)

Simple journaling from the command line written mostly to learn about OCaml.

# To compile:

You must have installed:

- OCaml
- opam

opam packages you need:

- core
- calendar

install them with: `opam install core calendar`

then to build a native binary: `make`


# Usage:

```
$ mj myJournalName "This is an entry"

```

Your journal will currently be saved to: `~/.myJournalName.md`


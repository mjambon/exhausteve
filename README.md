Exhausteve
==========

Exhausteve is an OCaml library and an executable that checks whether a
classic [regular expression](https://en.wikipedia.org/wiki/Regular_language)
matches all strings i.e. is equivalent to `.*`.

Here's a hello-world example:

```
$ echo ".?.?.?.?|......+|[^h]....|.[^e]...|..[^l]..|...[^l].|....[^o]" | ./exhausteve
The provided regular expression is not exhaustive.
Here is an example of nonmatching input:
"hello"
```

The algorithm is a standard conversion of a regular expression tree
into an
[NFA](https://en.wikipedia.org/wiki/Nondeterministic_finite_automaton)
and then into an equivalent
[DFA](https://en.wikipedia.org/wiki/Deterministic_finite_automaton)
which is then visited breadth-first
until a missing state transition is found.

The only optimization is the conversion of the original alphabet
(bytes) into character classes that group equivalent characters. This
massively reduces the number of possible state transitions and speeds
up the NFA/DFA construction accordingly.

The implementation also includes a simple regexp parser using Ocamllex
and Menhir.

Suggested uses
--------------

- Study the source code for inspiration.
- Use the NFA implementation to implement Thompson's algorithm which
  matches a string efficiently in O(regexp size × string length).
- Use the DFA implementation to generate efficient source code for
  matching a regular expression.
- Use as a model to add a similar exhaustiveness check to ocamllex.

Build and test
--------------

Install [opam](https://opam.ocaml.org/) if you don't have it already
on your machine. Run `make setup` to install the dependencies.
Run `make` to build the library and the `exhausteve` executable.
Run `make test` to test, `make demo` for a demo.
Look into the makefile for more.

Options
-------

To check whether a regular expression matches some prefix of an
arbitrary input string as in a lexer, use the prefix mode that is
selected with the `--mode prefix` option.

Consider the following ocamllex rule:
```
rule token = parse
| ['a'-'z']+  { WORD }
| ['0'-'9']+  { NUMBER }
| eof         { EOF }
```

We can check whether this `token` rule tolerates any input by checking
the disjunction of the patterns:
```
$ echo '[a-z]+ | [0-9]+ | $' | ./exhausteve --mode prefix
The provided regular expression is not exhaustive.
Here is an example of nonmatching input:
"\000"
```

This indicates that our ocamllex rule is broken. It might be fixed as
follows:

```
rule token = parse
| ['a'-'z']+  { WORD }
| ['0'-'9']+  { NUMBER }
| eof         { EOF }
| _ as c      { error lexbuf (sprintf "Invalid character %C" c) }
```

We can now check mechanically that the new rule is exhaustive:
```
$ echo '[a-z]+ | [0-9]+ | $ | .' | ./exhausteve --mode prefix
The provided regular expression is exhaustive.
```

Graphs etc.
-----------

The regular expression `. | (..)* | (...)*` is designed to match strings
of length 0, 1, multiples of 2, and multiples of 3. The shortest strings
that are not matched are of length 5. Our tool should report such a
string as an example of nonmatching input and it does:

```
$ echo '. | (..)* | (...)*' | ./exhausteve
The provided regular expression is not exhaustive.
Here is an example of nonmatching input:
"\000\000\000\000\000"
```

`exhausteve` dumps the files `nfa.dot` and `dfa.dot` that when fed to
`dot` give us a visual representation of the automata.
I find them interesting in the case of `. | (..)* |
(...)*`. Here's the NFA:

![NFA](img/demo-nfa.png "NFA")

And here's the DFA derived from the NFA:

![DFA](img/demo-dfa.png "DFA")

Note the two nodes (states) without an `eof` transition leading to the final
state, indicating that any string ending on one of these states will be
rejected by the automaton.

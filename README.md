Exhausteve
==========

Exhausteve is an OCaml library and an executable that checks whether a
classic regular expression matches all strings i.e. is equivalent to `.*`.

Here's a hello-world example:

```
$ echo ".?.?.?.?|......+|[^h]....|.[^e]...|..[^l]..|...[^l].|....[^o]" | ./exhausteve
The provided regular expression is not exhaustive.
Here is an example of nonmatching input:
"hello"
```

The algorithm is a standard conversion of a regular expression tree
into an NFA and then into a DFA which is then visited breadth-first
until a missing state transition is found.

The only optimization is the conversion of the original alphabet
(bytes) into character classes that group equivalent characters. This
massively reduces the number of possible state transitions and speeds
up the NFA/DFA construction accordingly.

The implementation also includes a simple regexp parser using ocamllex
and menhir.

Suggested uses
--------------

- Study the source code for inspiration.
- Use the NFA implementation to implement Thompson's algorithm which
  matches a string efficiently in O(regexp size × string length).
- Use the DFA implementation to generate efficient source code for
  matching a regular expression.
- Use as a model to add a similar exhaustiveness check to ocamllex.

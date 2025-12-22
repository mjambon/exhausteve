This is a collection of design notes and implementation notes for
future maintainers, human or not.

Goals
=====

Implement a proof-of-concept executable and/or library that takes a
collection of regular expressions and checks if their union matches
any input. If not, an example of invalid input is provided.

This could be used in a program such as ocamllex to check statically
whether a rule may fail to match some input.

This is a fun personal project implementing well-known algorithms.

Exhaustivess checking algorithm
===============================

Prerequisites
-------------

The reader need to be familiar with the following concepts:

- regular expression
- NFA (nondeterministic finite automaton)
- DFA (deterministic finite automaton)


Input preparation
-----------------

The starting point of the main algorithm is a single regular
expression (not a Perl-style regex(p)). Before checking the patterns in
an ocamllex rule, they have to be converted into a single regular
expression that is meant to match the whole input rather than a prefix
of the input (token).

Consider the following ocamllex rule:
```
rule token = parse
| ['a'-'z']+    { WORD }
| ['0'-'9']+    { NUMBER }
| eof           { EOF }
```

The regular expression derived from this rule is (in ocamllex syntax)
```
(['a'-'z']+ | ['0'-'9']+ | eof) _* eof
```
and it is fed to our exhaustiveness checking algorithm.

Other applications than ocamllex may not need such a transformation,
depending on whether the patterns are expected to match the whole
input of just a prefix.

Algorithm outline
-----------------

* The input is a single regular expression.
* Convert the regular expression into an NFA.
* Convert the NFA into an equivalent DFA.
* Identify any state in the DFA that is not an accepting state or
  any state is missing a transition and provide an example of input
  not recognized the automaton:
  - visit the graph in a breadth-first manner starting from the
    initial state
  - follow all edges (transitions) leading to unvisited nodes
  - as soon as a node is visited, mark it as such and store the input
    string that took us here i.e. the sequence of transitions from the
    start state.
  - as soon as we find a state is not an accepting state or if any
    transition is missing, our regular expression does not match any
    input. An example of input is the path taken when visiting the
    graph.

Testing
=======

A simple regular expression parser is included for testing purposes.

A test suite checks special cases.

A graph representing the DFA or the NFA can be exported
and rendered with Graphviz for debugging purposes or for pedagogical
purposes.

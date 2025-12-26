.PHONY: build
build:
	dune build @install

.PHONY: demo
demo:
	echo "a b* | c?" | ./exhausteve
	dot -Tpng nfa.dot -o nfa.png
	dot -Tpng dfa.dot -o dfa.png
	display nfa.png
	display dfa.png


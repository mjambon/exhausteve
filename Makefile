.PHONY: build
build:
	dune build @install

.PHONY: demo
demo:
	echo "a b* | c?" | ./exhausteve
	dot -Tpng nfa.dot -o nfa.png
	display nfa.png

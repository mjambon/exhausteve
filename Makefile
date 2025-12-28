.PHONY: build
build:
	dune build @install

.PHONY: demo
demo:
	echo "..ab * | c?" | ./exhausteve
	$(MAKE) graphs

# 'dot' is part of Graphviz.
# 'display' is part of ImageMagick.
.PHONY: graphs
graphs:
	dot -Tpng nfa.dot -o nfa.png
	dot -Tpng dfa.dot -o dfa.png
	display nfa.png &
	display dfa.png &

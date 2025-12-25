.PHONY: build
build:
	dune build @install

.PHONY: demo
demo:
	echo "a b* | c?" | ./exhausteve

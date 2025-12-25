(lang dune 3.20)

(name exhausteve)

(generate_opam_files true)

(source
 (github mjambon/exhausteve))

(authors "Martin Jambon <martin@mjambon.com>")

(maintainers "Martin Jambon <martin@mjambon.com>")

(license ISC)

(documentation https://url/to/documentation)

(using menhir 2.1)

(package
 (name exhausteve)
 (synopsis "A regular expression exhaustiveness checker")
 (description "A regular expression exhaustiveness checker")
 (depends ocaml)
 (tags
  ("regular expressions" "static analysis")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html

# bandit
ref: https://github.com/freuk/obandit

# dev with dune
ref: https://ocamlverse.github.io/content/quickstart_ocaml_project_dune.html

注意点
- dune_projectはrootディレクトリにしか置いてはいけない
- rootディレクトリからduneコマンドを実行する

## run test
edit test/test.ml, and
```
$ dune build test/test.exe
$ dune exec test/test.exe (or dune runtest (automatically aliased))
```

## duneプロジェクトで作成する場合
```
$ dune init project {project_name}
$ cd {project_name}
$ dune build
$ dune exec {project_name}
```

Add library in bin/dune
```
(libraries {library_name})
```
```
$ dune build
```
これでvscode上でもパスが通るようになる

## 最小プロジェクトで作成する場合
exercises/make_exercise_proj.shを参照
基本的には以下ファイルを用意し，ライブラリなどを追記した上でbuildすれば動くようになる
- mlファイル
- duneファイル
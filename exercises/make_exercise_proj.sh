#!/bin/bash

mkdir $1
cd $1
touch problem.ml dune
cat <<EOF > dune
(library
 (name problem)
 (libraries base stdio)
 (inline_tests)
 (preprocess (pps ppx_jane ppx_inline_test)))

(env
  (dev
    (flags (:standard
            -w -20 
            -w -27 
            -w -32 
            -w -34 
            -w -37 
            -w -39)))
  (release 
   (flags (:standard))))
EOF
dune build
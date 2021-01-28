#!/usr/bin/env bash

# dependency: iqtree version 1.6.12

din=../../results/dpigrum/supermatrix
dout=../../results/dpigrum/tree

threads=16

[ -d $dout ] || mkdir -p $dout

iqtree \
  -s $din/supermatrix_nucs_trimmed.fasta \
  -pre $dout/dpigrum \
  -m TEST \
  -alrt 1000 -bb 1000 \
  -nt $threads \
  -mem 14G

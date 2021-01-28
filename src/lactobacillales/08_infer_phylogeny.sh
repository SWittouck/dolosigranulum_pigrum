#!/usr/bin/env bash

# dependency: iqtree v1.6.12

din=../../results/lactobacillales/supermatrix
dout=../../results/lactobacillales/tree

threads=16

[ -d $dout ] || mkdir -p $dout

iqtree \
  -s $din/supermatrix_aas_trimmed.fasta \
  -pre $dout/lactobacillales \
  -m TEST \
  -alrt 1000 -bb 1000 \
  -nt $threads \
  -mem 14G

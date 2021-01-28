#!/usr/bin/env bash

# dependency: trimal 1.4.rev15

fin=../../results/dpigrum/supermatrix/supermatrix_nucs.fasta
fout=../../results/dpigrum/supermatrix/supermatrix_nucs_trimmed.fasta

# trim protein supermatrix: remove columns where > 50% of the sequences has a 
# gap
trimal \
  -in $fin \
  -out $fout \
  -gt 0.50 \
  -keepheader

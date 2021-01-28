#!/usr/bin/env bash

# dependency: trimal 1.4.rev15

fin=../../results/lactobacillales/supermatrix/supermatrix_aas.fasta
fout=../../results/lactobacillales/supermatrix/supermatrix_aas_trimmed.fasta

# trim protein supermatrix: remove columns where > 5% of the sequences has a 
# gap
trimal \
  -in $fin \
  -out $fout \
  -gt 0.95 \
  -keepheader

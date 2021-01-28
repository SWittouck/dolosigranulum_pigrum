#!/usr/bin/env bash

# dependencies: ProClasp v1.0

fin=../../results/lactobacillales/genomes_accessions.txt
dout=../../data/genomes_lactobacillales_ncbi
fout_log=../../results/lactobacillales/download_fnas.log

if ! [ -d $dout ] ; then

  download_fnas.sh $fin $dout 2>&1 | tee $fout_log

fi
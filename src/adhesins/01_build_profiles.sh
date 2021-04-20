#!/usr/bin/env bash

# The goal of this script is to build a profile HMM database of the pangenome 
# of the species D. pigrum.

# dependencies: SCARAP v0.3.1

fin_faapaths=../../results/dpigrum/faapaths.txt
fin_pangenome=../../results/dpigrum/pan/pangenome.tsv
dout=../../results/adhesin_search

threads=16

[ -d $dout ] || mkdir -p $dout

scarap build -t $threads $fin_faapaths $fin_pangenome $dout/pan_db
# rm -r $dout/pan_db/alignments
# rm -r $dout/pan_db/orthogroups
# rm -r $dout/pan_db/profiles

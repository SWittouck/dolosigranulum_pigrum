#!/usr/bin/env bash

# The goal of this script is to scan a pangenome profile HMM database of D. 
# pigrum for adhesin genes. 

# dependencies: HMMER v3.3.1

fin_profile_db=../../results/adhesin_search/pan_db/hmm_db
fin_adhesins=../../data/spaCBA_LGG_aas.fasta
dout=../../results/adhesin_search

[ -d $dout ] || mkdir -p $dout

hmmscan \
  --domtblout $dout/scores.tsv \
  $fin_profile_db \
  $fin_adhesins
#!/usr/bin/env bash

# dependencies: progenomics 13b9be1

din_faas=../../results/dpigrum/genes/faas
dout=../../results/dpigrum

threads=16

# infer the pangenome of all genomes
ls $din_faas/*.faa.gz > $dout/faapaths.txt
progenomics pan $dout/faapaths.txt $dout/pan -t $threads

# assess the observed occurrence of all orthogroups
progenomics checkgroups $dout/pan/pangenome.tsv $dout/orthogroups

# select the 1000 orthogroups with the highest single-copy occurrence
# IMPORTANT REMARK: the "tr" part is only for systems where the decimal 
# separator is set to ","
cat $dout/orthogroups/orthogroups.tsv | \
   tr '.' ',' | sort -k3 -n | tail -n 1000 | cut -f1 \
  > $dout/orthogroups/core1000_orthogroups.txt

# make a core genome file with these 1000 orthogroups
progenomics filter $dout/pan/pangenome.tsv $dout/core -o \
  $dout/orthogroups/core1000_orthogroups.txt

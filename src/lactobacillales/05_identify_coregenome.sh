#!/usr/bin/env bash

# dependencies: progenomics 13b9be1

din_faas=../../results/lactobacillales/genes/faas
dout=../../results/lactobacillales

threads=16

gunzip $din_faas/*.faa.gz

ls $din_faas/*.faa > $dout/faapaths.txt
progenomics pan $dout/faapaths.txt $dout/pan -t $threads
progenomics checkgroups $dout/pan/pangenome.tsv $dout/orthogroups
awk '{ if ($2 > 0.95) { print $1 } }' $dout/orthogroups/orthogroups.tsv \
  > $dout/orthogroups/core_orthogroups.txt
progenomics filter $dout/pan/pangenome.tsv $dout/core -o \
  $dout/orthogroups/core_orthogroups.txt

gzip $din_faas/*.faa

rm -r $dout/pan/superfamilies
rm -r $dout/pan/tmp 
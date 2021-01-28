#!/usr/bin/env bash

# This script calculates the pairwise ANI values (using all genes present in 
# both genomes) for all genomes.

# dependencies: progenomics version ad74c8e

# din_faas=../../results/dpigrum/genes/faas
din_ffns=../../results/dpigrum/genes/ffns
fin_pan=../../results/dpigrum/pan/pangenome.tsv
# fio_faapaths=../../results/dpigrum/faapaths.txt
fio_ffnpaths=../../results/dpigrum/ffnpaths.txt
dout=../../results/dpigrum/anis

# ls $din_faas/*.faa.gz > $fio_faapaths
ls $din_ffns/*.ffn.gz > $fio_ffnpaths

progenomics clust $fio_ffnpaths $fin_pan $dout --threads 16
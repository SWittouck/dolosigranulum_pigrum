#!/usr/bin/env bash

# dependencies: progenomics 13b9be1

din_faas=../../results/lactobacillales/genes/faas
# din_ffns=../../results/lactobacillales/genes/ffns
fin_coregenome=../../results/lactobacillales/core/pangenome.tsv
fio_faapaths=../../results/lactobacillales/faapaths.txt
# fio_ffnpaths=../../results/lactobacillales/ffnpaths.txt
dout=../../results/lactobacillales/supermatrix

gunzip $din_faas/*.faa.gz
# gunzip $din_ffns/*.ffn.gz

ls $din_faas/*.faa > $fio_faapaths
# ls $din_ffns/*.ffn > $fio_ffnpaths
progenomics supermatrix $fio_faapaths $fin_coregenome $dout

gzip $din_faas/*.faa
# gzip $din_ffns/*.ffn

rm -r $dout/seqs_aas
# rm -r $dout/seqs_nucs
rm -r $dout/alis_aas
# rm -r $dout/alis_nucs
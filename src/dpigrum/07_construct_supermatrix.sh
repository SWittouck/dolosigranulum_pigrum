#!/usr/bin/env bash

# dependencies: progenomics 13b9be1

din_faas=../../results/dpigrum/genes/faas
din_ffns=../../results/dpigrum/genes/ffns
fin_coregenome=../../results/dpigrum/core/pangenome.tsv
fio_faapaths=../../results/dpigrum/faapaths.txt
fio_ffnpaths=../../results/dpigrum/ffnpaths.txt
dout=../../results/dpigrum/supermatrix

ls $din_faas/*.faa.gz > $fio_faapaths
ls $din_ffns/*.ffn.gz > $fio_ffnpaths
progenomics supermatrix $fio_faapaths $fin_coregenome $dout \
  --ffnpaths $fio_ffnpaths
#!/bin/bash

# dependency: prodigal v2.6.3

threads=16

din_fnas_ncbi=../../data/genomes_dpigrum_ncbi
din_fnas_nayfach=../../data/genomes_dpigrum_nayfach
din_fnas_isolates=../../results/dpigrum/genomes_isolates
dout_prodigal=../../results/dpigrum/genes

# make output dirs if they don't exist
for dout in $dout_prodigal/{gffs,ffns,faas,logs} ; do
  [ -d $dout ] || mkdir -p $dout
done

# function to predict genes for one genome
predict_genes() {

  fin_genome=$1
  dout_prodigal=$2
  
  # extract genome name from path
  re="((GC[AF]_[0-9]+\.[0-9])|(AMBR[0-9]+)|([0-9]+_[0-9]+))"
  [[ $fin_genome =~ $re ]] && genome=${BASH_REMATCH[1]}
  
  # exit function if faa already exists
  [[ ! -f $dout_prodigal/faas/${genome}.faa.gz ]] || return 0

  # unzip genome
  gunzip $fin_genome

  # run prodigal
  prodigal \
    -f gff \
    -i ${fin_genome%.gz} \
    -o $dout_prodigal/gffs/${genome}.gff \
    -d $dout_prodigal/ffns/${genome}.ffn \
    -a $dout_prodigal/faas/${genome}.faa \
    2> $dout_prodigal/logs/${genome}.txt

  # rezip genome
  gzip ${fin_genome%.gz}

}

export -f predict_genes

# predict genes for gtdb genomes
parallel \
  --jobs $threads \
  --no-notice \
  --verbose \
  predict_genes {.} $dout_prodigal \
  ::: $din_fnas_ncbi/*.fna.gz

# predict genes for nayfach genomes
parallel \
  --jobs $threads \
  --no-notice \
  --verbose \
  predict_genes {.} $dout_prodigal \
  ::: $din_fnas_nayfach/*.fna.gz

# predict genes for isolate genomes
parallel \
  --jobs $threads \
  --no-notice \
  --verbose \
  predict_genes {.} $dout_prodigal \
  ::: $din_fnas_isolates/*.fna.gz

# zip genes in parallel
parallel \
  --jobs $threads \
  --no-notice \
  --verbose \
  gzip {} \
  ::: $dout_prodigal/{gffs,ffns,faas}/*

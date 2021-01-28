#!/usr/bin/env bash

# dependencies: ProClasp v1.0

fin_gtdb=../../results/dpigrum/gtdb_accessions.txt
fin_nayfach=../../results/dpigrum/nayfach_accessions.txt
dout_gtdb=../../data/genomes_dpigrum_ncbi
dout_nayfach=../../data/genomes_dpigrum_nayfach
fout_gtdb_log=../../results/dpigrum/download_fnas_gtdb.log
fout_nayfach_log=../../results/dpigrum/download_fnas_nayfach.log

# download gtdb genomes from ncbi
if ! [ -d $dout_gtdb ] ; then

  download_fnas.sh $fin_gtdb $dout_gtdb 2>&1 | tee $fout_log

fi

# download Nayfach et al. (2020) MAGs from nersc.gov
if ! [ -d $dout_nayfach ] ; then

  mkdir $dout_nayfach

  for accession in $(cat $fin_nayfach) ; do
  
    url=https://portal.nersc.gov/GEM/genomes/fna/$accession.fna.gz
    echo $url
    [ -f $dout_nayfach/$accession.fna.gz ] || wget $url -P $dout_nayfach
    
  done

fi
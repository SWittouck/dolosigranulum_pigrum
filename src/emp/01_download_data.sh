#!/usr/bin/env bash 

dout_data=../../data/emp_cr_silva_16S_123.subset
dout_emp=../../results/emp

[ -d $dout_data ] || mkdir -p $dout_data
[ -d $dout_emp ] || mkdir -p $dout_emp

cd $dout_data

wget ftp://ftp.microbio.me/emp/release1/otu_tables/closed_ref_silva/emp_cr_silva_16S_123.subset_10k.rare_10000.biom
wget ftp://ftp.microbio.me/emp/release1/mapping_files/emp_qiime_mapping_subset_10k.tsv
wget ftp://ftp.microbio.me/emp/release1/otu_info/silva_123/97_otus_16S.fasta

cd -

cp $dout_data/emp_qiime_mapping_subset_10k.tsv $dout_emp/samples.tsv

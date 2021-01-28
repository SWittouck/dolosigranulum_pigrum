#!/usr/bin/env Rscript

# dependencies: tidyverse v1.3.0

library(tidyverse)

url_gtdb <- "https://data.ace.uq.edu.au/public/gtdb/data/releases/release95/95.0/bac120_metadata_r95.tar.gz"
dout <- "../../data"
fout_tmp_tar <- paste0(dout, "/bac120_metadata_r95.tar.gz")
fout_tmp <- paste0(dout, "/bac120_metadata_r95.tsv")
fout_metadata <- paste0(dout, "/gtdb_r95_metadata_lactobacillales.tsv")

if (! dir.exists(dout)) dir.create(dout)

if (! file.exists(fout_tmp_tar)) {
  download.file(url_gtdb, destfile = fout_tmp_tar)
}
  
untar(fout_tmp_tar, exdir = dout)
genomes_gtdb <- read_tsv(fout_tmp)

genomes_gtdb %>%
  mutate(gtdb_order = str_extract(gtdb_taxonomy, "o__[a-zA-Z]+")) %>%
  filter(gtdb_order == "o__Lactobacillales") %>%
  select(- gtdb_order) %>%
  write_tsv(fout_metadata)

file.remove(fout_tmp_tar)
file.remove(fout_tmp)

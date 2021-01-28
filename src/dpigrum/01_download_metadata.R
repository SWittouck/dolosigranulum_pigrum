#!/usr/bin/env Rscript

# dependencies: tidyverse v1.3.0

library(tidyverse)

url_gtdb <- "https://data.ace.uq.edu.au/public/gtdb/data/releases/release95/95.0/bac120_metadata_r95.tar.gz"
url_nayfach <- "https://portal.nersc.gov/GEM/genomes/genome_metadata.tsv"
fin_nayfach <- "../../data/41587_2020_718_MOESM3_ESM.xlsx"
dout <- "../../data"

# define paths to output files
fout_gtdb_tmp_tar <- paste0(dout, "/bac120_metadata_r95.tar.gz")
fout_gtdb_tmp_tsv <- paste0(dout, "/bac120_metadata_r95.tsv")
fout_gtdb <- paste0(dout, "/gtdb_r95_metadata_dpigrum.tsv")
fout_nayfach_tmp <- paste0(dout, "/nayfach2020_metadata.tsv")
fout_nayfach <- paste0(dout, "/nayfach2020_metadata_dpigrum.tsv")

# create data folder if it doesn't exist
if (! dir.exists(dout)) dir.create(dout)

# download gtdb metdata
if (! file.exists(fout_gtdb_tmp_tar)) {
  download.file(url_gtdb, destfile = fout_gtdb_tmp_tar)
}

# download nayfach et al. metadata
if (! file.exists(fout_nayfach_tmp)) {
  download.file(url_nayfach, destfile = fout_nayfach_tmp)
}

# read the metadata files
untar(fout_gtdb_tmp_tar, exdir = dout)
genomes_gtdb <- read_tsv(fout_gtdb_tmp_tsv, col_types = cols())
genomes_nayfach <- read_tsv(fout_nayfach_tmp, col_types = cols())

# add extra metadata from nayfach et al. supplementary excel file
nayfach_samples <- 
  fin_nayfach %>% 
  readxl::read_excel(sheet = "S1") %>%
  rename_with(str_to_lower) %>%
  select(
    metagenome_id = img_taxon_id, ecosystem_subtype, specific_ecosystem, 
    habitat, biosample_name, biosample_id
  )

# extract the D. pigrum genomes and write their metadata
genomes_gtdb %>%
  mutate(gtdb_species = str_extract(gtdb_taxonomy, "(?<=s__)[^;]+")) %>%
  filter(gtdb_species == "Dolosigranulum pigrum") %>%
  select(- gtdb_species) %>%
  write_tsv(fout_gtdb)
genomes_nayfach %>%
  mutate(gtdb_species = str_extract(taxonomy, "(?<=s__)[^;]+")) %>%
  filter(gtdb_species == "Dolosigranulum pigrum") %>%
  select(- gtdb_species) %>%
  left_join(nayfach_samples, by = "metagenome_id") %>%
  # some genome ids are in the dataset multiple times!!! 
  distinct() %>%
  write_tsv(fout_nayfach)

# remove temporary files
file.remove(fout_gtdb_tmp_tar)
file.remove(fout_gtdb_tmp_tsv)
file.remove(fout_nayfach_tmp)

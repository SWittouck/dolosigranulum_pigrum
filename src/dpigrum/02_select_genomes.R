#!/usr/bin/env Rscript

# dependencies: tidyverse v1.3.0

library(tidyverse)

fin_gtdb <- "../../data/gtdb_r95_metadata_dpigrum.tsv"
fin_nayfach <- "../../data/nayfach2020_metadata_dpigrum.tsv"
dout <- "../../results/dpigrum"

if (! dir.exists(dout)) dir.create(dout, recursive = T)

genomes_gtdb <- fin_gtdb %>% read_tsv(col_types = cols())
genomes_nayfach <- fin_nayfach %>% read_tsv(col_types = cols())

genomes_gtdb %>%
  select(
    ncbi_genbank_assembly_accession, checkm_completeness, checkm_contamination
  ) %>%
  pivot_longer(
    cols = c(checkm_completeness, checkm_contamination), names_to = "variable",
    values_to = "value"
  ) %>%
  ggplot(aes(x = ncbi_genbank_assembly_accession, y = value)) +
  geom_col() +
  facet_wrap(~ variable) +
  xlab("") +
  coord_flip() +
  theme_bw()
ggsave(
  paste0(dout, "/gtdb_quality.png"), units = "cm", width = 16, 
  height = 10
)

genomes_nayfach %>%
  select(genome_id, completeness, contamination) %>%
  pivot_longer(
    cols = c(completeness, contamination), names_to = "variable",
    values_to = "value"
  ) %>%
  ggplot(aes(x = genome_id, y = value)) +
  geom_col() +
  facet_wrap(~ variable) +
  xlab("") +
  coord_flip() +
  theme_bw()
ggsave(
  paste0(dout, "/nayfach2020_quality.png"), units = "cm", width = 16, 
  height = 10
)

selected_gtdb <- genomes_gtdb
nrow(selected_gtdb)

selected_nayfach <- genomes_nayfach
nrow(selected_gtdb)

selected_gtdb %>%
  write_csv(paste0(dout, "/gtdb_metadata.csv"))
selected_gtdb %>%
  select(ncbi_genbank_assembly_accession) %>%
  write_tsv(paste0(dout, "/gtdb_accessions.txt"), col_names = F)

selected_nayfach %>%
  write_csv(paste0(dout, "/nayfach_metadata.csv"))
selected_nayfach %>%
  select(genome_id) %>%
  write_tsv(paste0(dout, "/nayfach_accessions.txt"), col_names = F)

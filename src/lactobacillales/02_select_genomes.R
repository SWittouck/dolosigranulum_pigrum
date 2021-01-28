#!/usr/bin/env Rscript

# dependencies: tidyverse v1.3.0

library(tidyverse)

fin_metadata <- "../../data/gtdb_r95_metadata_lactobacillales.tsv"
dout <- "../../results/lactobacillales"

quality_cutoff <- 95

if (! dir.exists(dout)) dir.create(dout, recursive = T)

genomes_all <- 
  fin_metadata %>%
  read_tsv(col_types = cols())

genomes_all <-
  genomes_all %>%
  mutate(
    gtdb_species = str_extract(gtdb_taxonomy, "s__[^;]+"),
    gtdb_genus = str_extract(gtdb_taxonomy, "g__[^;]+"),
    gtdb_family = str_extract(gtdb_taxonomy, "f__[^;]+")
  )  %>%
  mutate(quality = checkm_completeness - checkm_contamination)

genomes_noncarno <-
  genomes_all %>%
  filter(gtdb_family != "f__Carnobacteriaceae") %>%
  group_by(gtdb_genus) %>%
  arrange(desc(quality)) %>%
  mutate(top_quality = 1:n() == 1) %>%
  ungroup()

genomes_noncarno %>%
  arrange(top_quality) %>%
  ggplot(aes(x = gtdb_genus, y = quality, col = top_quality)) +
  geom_jitter(height = 0, width = 0.2, size = 1) +
  geom_hline(yintercept = quality_cutoff, col = "grey") +
  scale_color_brewer(palette = "Paired") +
  theme_bw() +
  theme(legend.position = "bottom") +
  coord_flip() 
ggsave(
  paste0(dout, "/quality_noncarno.png"), units = "cm", width = 12, height = 26
)

selected_noncarno <-
  genomes_noncarno %>%
  filter(top_quality, quality >= quality_cutoff)
nrow(selected_noncarno)

genomes_carno <-
  genomes_all %>%
  filter(gtdb_family == "f__Carnobacteriaceae") %>%
  group_by(gtdb_species) %>%
  arrange(desc(quality)) %>%
  mutate(top_quality = 1:n() == 1) %>%
  ungroup()

genomes_carno %>%
  arrange(top_quality) %>%
  ggplot(aes(x = gtdb_species, y = quality, col = top_quality)) +
  geom_jitter(height = 0, width = 0.2, size = 1) +
  geom_hline(yintercept = quality_cutoff, col = "grey") +
  scale_color_brewer(palette = "Paired") +
  theme_bw() +
  theme(legend.position = "bottom") +
  coord_flip()
ggsave(
  paste0(dout, "/quality_carno.png"), units = "cm", width = 12, height = 15
)

selected_carno <-
  genomes_carno %>%
  filter(top_quality, quality >= quality_cutoff)
nrow(selected_carno)

selected <- bind_rows(selected_noncarno, selected_carno)
nrow(selected)

selected %>%
  write_csv(paste0(dout, "/genomes_metadata.csv"))
selected %>%
  select(ncbi_genbank_assembly_accession) %>%
  write_tsv(paste0(dout, "/genomes_accessions.txt"), col_names = F)

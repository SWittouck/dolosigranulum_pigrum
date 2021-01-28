#!/usr/bin/env Rscript

# dependencies: tidyverse v1.3.0, tidygenomes v0.1.3

library(tidyverse)
library(tidygenomes)

source("estimation_functions.R")

fin_genomes <- "../../results/dpigrum/genomes_metadata.csv"
fin_pan <- "../../results/dpigrum/pan/pangenome.tsv"
dout <- "../../results/dpigrum"

if (! dir.exists(dout)) dir.create(dout)

# read genomes
genomes <- 
  fin_genomes %>%
  read_csv(col_types = cols())

# read pangenome
pan <-
  fin_pan %>%
  read_tsv(col_names = c("gene", "genome", "orthogroup"), col_types = cols())

# create tidygenomes object and add pangenome estimates
dpigrum <-
  as_tidygenomes(genomes) %>%
  add_tidygenomes(pan) %>%
  add_orthogroup_measures() %>%
  add_pangenome_estimates() %>%
  modify_at(
    "orthogroups", mutate, 
    core_acc = if_else(occurrence_est >= 0.99, "core", "accessory")
  )

# does the estimated completeness agree with checkm? 
dpigrum$genomes %>% 
  select(strain, completeness, completeness_est) %>%
  arrange(completeness_est)

# exploration of orthogroups
dpigrum$orthogroups %>%
  mutate(rank = rank(- og_genomes, ties.method = "first")) %>%
  ggplot(aes(x = rank, y = og_genomes)) +
  geom_line() +
  theme_bw() +
  xlab("orthogroup") +
  ylab("# genomes")

# number of core orthogroups 
dpigrum$orthogroups %>%
  filter(core_acc == "core") %>%
  nrow()

# number of core orthogroups (crude estimation strategy as verification)
dpigrum %>%
  filter_genomes(completeness >= 98) %>%
  modify_at("orthogroups", select, - og_genomes, - og_genes) %>%
  add_orthogroup_measures() %>%
  filter_orthogroups(og_genomes == max(og_genomes)) %>%
  {nrow(.$orthogroups)}

# number of accessory and uique orthogroups in AMBR11
orthogroups_ambr11 <-
  dpigrum %>%
  filter_genomes(strain == "AMBR11") %>%
  pluck("orthogroups")
filter(orthogroups_ambr11, core_acc == "accessory") %>% nrow()
filter(orthogroups_ambr11, og_genomes == 1) %>% nrow()

# number of accessory and uique orthogroups in AMBR12
orthogroups_ambr12 <-
  dpigrum %>%
  filter_genomes(strain == "AMBR12") %>%
  pluck("orthogroups")
filter(orthogroups_ambr12, core_acc == "accessory") %>% nrow()
filter(orthogroups_ambr12, og_genomes == 1) %>% nrow()

# number of accessory genes per genome
genomes_counts <-
  dpigrum$genes %>%
  left_join(dpigrum$orthogroups, by = "orthogroup") %>%
  group_by(genome) %>%
  summarize(
    n_core = sum(core_acc == "core"), 
    n_accessory = sum(core_acc == "accessory"), 
    n_genes = n(), .groups = "drop"
  ) %>%
  left_join(dpigrum$genomes, by = "genome") %>%
  arrange(n_genes) %>%
  mutate(strain_fct = factor(strain, levels = strain)) %>%
  select(genome, strain_fct, n_genes, n_core, n_accessory)
genomes_counts %>%
  write_tsv(paste0(dout, "/genomes_core_accessory.tsv"))
genomes_counts %>%
  summarize(mean_acc = mean(n_accessory), sd_acc = sd(n_accessory))

# visualization of core and accessory genome
genomes_counts %>%
  pivot_longer(
    cols = c(n_core, n_accessory), names_to = "core_acc", values_to = "count"
  ) %>%
  ggplot(aes(x = strain_fct, y = count, fill = core_acc)) +
  geom_col() +
  xlab("") + ylab("# genes") +
  coord_flip() +
  scale_fill_brewer(palette = "Paired") +
  theme_bw() +
  theme(legend.position = "bottom")
ggsave(
  paste0(dout, "/core_accessory.png"), units = "cm", width = 12, 
  height = 16
)

#!/usr/bin/env Rscript

# dependencies: tidyverse v1.3.0, tidygenomes v0.1.3, ggtree v2.0.2

library(tidyverse)
library(tidygenomes)
library(ggtree)

fin_tree <- "../../results/lactobacillales/tree/lactobacillales.treefile"
fin_genomes <- "../../results/lactobacillales/genomes_metadata.csv"
fin_pan <- "../../results/lactobacillales/pan/pangenome.tsv"
fin_zheng <- "../../data/zheng2020_table_S1_corrected.xlsx"
fin_nayfach <- "../../data/41587_2020_718_MOESM3_ESM.xlsx"
dout <- "../../results/lactobacillales"

if (! dir.exists(dout)) dir.create(dout)

# read tree
tree <- ape::read.tree(fin_tree)

# read genomes
genomes <- 
  fin_genomes %>%
  read_csv(col_types = cols()) %>%
  rename(genome = ncbi_genbank_assembly_accession)  %>%
  mutate(species = str_remove(gtdb_species, "^s__"))

# read species with lifestyles (zheng2020)
species_zheng <-
  fin_zheng %>%
  readxl::read_excel() %>%
  select(
    species = `proposed new species name`, lifestyle_zheng = lifestyle
  ) %>%
  mutate(species = str_extract(species, "^[^ ]+ [^ ]+")) %>%
  mutate(lifestyle_zheng = str_to_lower(lifestyle_zheng)) %>%
  filter(! is.na(lifestyle_zheng), lifestyle_zheng != "unknown") %>%
  distinct()

# find mammal-adapted species (nayfach2020)
nayfach_samples <- fin_nayfach %>% readxl::read_excel(sheet = "S1")
nayfach_mags <- fin_nayfach %>% readxl::read_excel(sheet = "S2")
nayfach_otus <- fin_nayfach %>% readxl::read_excel(sheet = "S5")
species_nayfach <-
  # for each mag: retrieve metadata of its sample and taxonomy of its species
  nayfach_mags %>%
  left_join(nayfach_otus, by = c("species_id" = "otu_id")) %>%
  left_join(nayfach_samples, by = c("img_taxon_id" = "IMG_TAXON_ID")) %>%
  select(
    genome_id, ecosystem = ECOSYSTEM, ecosystem_category = ECOSYSTEM_CATEGORY, 
    gtdb_taxonomy
  ) %>%
  # determine known lifestyles (can be multiple!) of each known species
  mutate(species = str_extract(gtdb_taxonomy, "(?<=s__)[^;]+")) %>%
  filter(! is.na(species)) %>%
  mutate(lifestyle_nayfach = case_when(
    ecosystem_category %in% c("Birds", "Fish", "Human", "Mammals") ~ 
      "vertebrate-adapted",
    ecosystem_category == "Plants" ~ "plant-adapted",
    ecosystem_category == "Insecta" ~ "insect-adapted",
    ecosystem == "Environmental" ~ "free-living",
    TRUE ~ "unknown"
  )) %>%
  filter(lifestyle_nayfach != "unknown") %>%
  # assign nomadic lifestyle to species with more than one lifestyle
  distinct(species, gtdb_taxonomy, lifestyle_nayfach) %>%
  add_count(species, name = "n_lifestyles") %>%
  mutate(
    lifestyle_nayfach = if_else(n_lifestyles > 1, "nomadic", lifestyle_nayfach)
  ) %>%
  distinct(species, gtdb_taxonomy, lifestyle_nayfach) %>%
  # filter to species of the order Lactobacillales
  filter(str_extract(gtdb_taxonomy, "o__[^;]+") == "o__Lactobacillales") %>%
  select(- gtdb_taxonomy)

# read pangenome
pan <- 
  fin_pan %>%
  read_tsv(col_names = c("gene", "genome", "orthogroup"), col_types = cols())

# prepare tidygenomes object and root tree based on outgroup
root <- 
  c(
    "Dolosigranulum pigrum", "Listeria monocytogenes_B", 
    "Brochothrix thermosphacta"
  )
probiotics <- 
  c(
    "Lactobacillus", "Limosilactobacillus", "Ligilactobacillus", 
    "Lacticaseibacillus", "Lactiplantibacillus", "Latilactobacillus", 
    "Streptococcus", "Enterococcus", "Lactococcus", "Leuconostoc", 
    "Pediococcus"
  )
lacto <-
  as_tidygenomes(tree) %>%
  add_tidygenomes(pan) %>%
  modify_at("genomes", left_join, genomes, by = "genome") %>%
  modify_at("genomes", left_join, species_zheng, by = "species") %>%
  modify_at("genomes", left_join, species_nayfach, by = "species") %>%
  modify_at(
    "genomes", mutate, 
    probiotic = str_extract(gtdb_taxonomy, "(?<=g__)[^;]+") %in% probiotics,
    family = str_extract(gtdb_taxonomy, "(?<=f__)[^;]+"),
    probiotic_label = 
      case_when(
        probiotic ~ "P", species == "Dolosigranulum pigrum" ~ "D", TRUE ~ ""
      )
  ) %>%
  modify_at(
    "nodes", mutate, 
    support_sh = node_label %>% str_extract("^[0-9]+") %>% as.double(), 
    support_bs = node_label %>% str_extract("[0-9]+$") %>% as.double(),
    trustworthy = support_sh >= 80 & support_bs >= 95
  ) %>%
  root_tree(genome_identifier = species, root = root)

# visualize tree with labels
lacto %>%
  modify_at(
    "genomes", mutate, 
    fontface = if_else(species == "Dolosigranulum pigrum", "bold", "plain")
  ) %>%
  ggtree_augmented(layout = "rectangular", size = 0.5, col = "grey") +
  geom_tiplab(
    aes(label = species, fontface = fontface), size = 1.5, align = T, 
    linesize = 0.2, offset = 0.002
  ) + 
  geom_point(aes(col = trustworthy), size = 1) +
  scale_color_brewer(palette = "Paired") +
  xlim(c(0, 2)) +
  theme(legend.position = "bottom")
ggsave(
  paste0(dout, "/tree_lactobacillales_labels.png"), units = "cm", width = 17.4,
  height = 30
)

# visualize tree without labels
lacto %>%
  ggtree_augmented(layout = "rectangular", size = 0.5, col = "grey") +
  geom_tiplab(
    aes(label = probiotic_label), fontface = "bold", size = 1.5, linesize = 0.2, 
    offset = 0.02
  ) + 
  geom_point(aes(shape = trustworthy), col = "grey", size = 1.5) +
  geom_tippoint(aes(col = family)) +
  scale_color_brewer(palette = "Paired") +
  scale_shape_manual(values = c("TRUE" = 16, "FALSE" = 1), guide = F) +
  xlim(c(0, 1.7)) +
  theme(legend.position = "right")
ggsave(
  paste0(dout, "/tree_lactobacillales.png"), units = "cm", width = 17.4, 
  height = 16
)

# visualize tree without labels in a circle
lacto %>%
  ggtree_augmented(layout = "circular", size = 0.5, col = "grey") +
  geom_tiplab2(
    aes(label = probiotic_label), fontface = "bold", size = 2, linesize = 0.2, 
    offset = 0.04
  ) + 
  # geom_point(aes(shape = trustworthy), col = "grey", size = 1.5) +
  geom_tippoint(aes(col = family), size = 1) +
  scale_color_brewer(palette = "Paired") +
  scale_shape_manual(values = c("TRUE" = 16, "FALSE" = 1), guide = F) +
  xlim(c(0, 1.7)) +
  theme(legend.position = "right")
ggsave(
  paste0(dout, "/tree_lactobacillales_circle.png"), units = "cm", width = 17.4, 
  height = 16
)

# visualize genome size ordered by tree
tips_ordered <-
  lacto$tree %>%
  {
    tip_ixs_orderd <- .$edge[.$edge[, 2] <= length(.$tip.label), 2]
    .$tip.label[tip_ixs_orderd]
  }
lacto$genomes %>%
  mutate(
    d_pigrum = 
      if_else(species == "Dolosigranulum pigrum", "D. pigrum", "other")
  ) %>%
  mutate(d_pigrum = factor(d_pigrum, levels = c("other", "D. pigrum"))) %>%
  mutate(node_fct = factor(node, levels = tips_ordered)) %>%
  arrange(node_fct) %>%
  mutate(species_fct = factor(species, levels = species)) %>%
  ggplot(aes(x = species_fct, y = protein_count, fill = d_pigrum)) +
  geom_col() +
  scale_fill_brewer(palette = "Paired") +
  theme_bw() +
  theme(legend.position = "bottom") +
  xlab("") +
  ylab("# proteins") +
  coord_flip()
ggsave(
  paste0(dout, "/protein_count.png"), units = "cm", width = 17.4, 
  height = 40
)

# visualize genome size in increasing order
plot_genome_size <- function(genomes, fill) {
  
  fill <- rlang::enexpr(fill)
  
  genomes %>%
    arrange(protein_count) %>%
    mutate(species_fct = factor(species, levels = species)) %>%
    ggplot(aes(x = species_fct, y = protein_count, fill = {{fill}})) +
    geom_col() +
    scale_fill_brewer(palette = "Paired", na.value = "grey90") +
    theme_bw() +
    theme(legend.position = "bottom") +
    xlab("") +
    ylab("# proteins") +
    coord_flip()
  
}
lacto$genomes %>%
  mutate(
    d_pigrum = 
      if_else(species == "Dolosigranulum pigrum", "D. pigrum", "other")
  ) %>%
  mutate(d_pigrum = factor(d_pigrum, levels = c("other", "D. pigrum"))) %>%
  plot_genome_size(fill = d_pigrum)
ggsave(
  paste0(dout, "/protein_count_increasing.png"), units = "cm", width = 17.4, 
  height = 40
)
lacto$genomes %>% 
  mutate(
    lifestyle_zheng = 
      if_else(species == "Dolosigranulum pigrum", "D. pigrum", lifestyle_zheng)
  ) %>%
  plot_genome_size(fill = lifestyle_zheng)
ggsave(
  paste0(dout, "/protein_count_increasing_zheng.png"), units = "cm", 
  width = 17.4, height = 40
)
lacto$genomes %>% plot_genome_size(fill = lifestyle_nayfach)
ggsave(
  paste0(dout, "/protein_count_increasing_nayfach.png"), units = "cm", 
  width = 17.4, height = 40
)

# print table with number of proteins for species 
lacto$genomes %>%
  select(species, lifestyle_nayfach, lifestyle_zheng, protein_count) %>%
  write_csv(paste0(dout, "/protein_counts.csv"))

# visualize number of shared orthogroups with D. pigrum
add_genome_measures <- function(tg) {
  genomes_measures <-
    tg$genes %>%
    group_by(genome) %>%
    summarize(
      n_orthogroups = unique(orthogroup) %>% length(),
      n_genes = n(), .groups = "drop"
    )
  tg$genomes <- tg$genomes %>% left_join(genomes_measures) 
  tg
}
orthogroups_dolo <-
  lacto$genes %>%
  left_join(lacto$genomes, by = "genome") %>%
  filter(gtdb_genus == "g__Dolosigranulum") %>%
  pull(orthogroup) %>%
  unique()
lacto %>%
  filter_orthogroups(orthogroup %in% orthogroups_dolo) %>%
  add_genome_measures() %>%
  pluck("genomes") %>%
  select(gtdb_family, gtdb_genus, gtdb_species, n_orthogroups, node) %>%
  mutate(
    d_pigrum = 
      if_else(gtdb_species == "s__Dolosigranulum pigrum", "D. pigrum", "other")
  ) %>%
  mutate(d_pigrum = factor(d_pigrum, levels = c("other", "D. pigrum"))) %>%
  mutate(node_fct = factor(node, levels = tips_ordered)) %>%
  arrange(node_fct) %>%
  mutate(gtdb_species_fct = factor(gtdb_species, levels = gtdb_species)) %>%
  ggplot(aes(x = gtdb_species_fct, y = n_orthogroups, fill = d_pigrum)) +
  geom_col() +
  scale_fill_brewer(palette = "Paired") +
  theme_bw() +
  theme(legend.position = "bottom") +
  xlab("") +
  ylab("# orthogroups shared with Dolosigranulum pigrum") +
  coord_flip()
ggsave(
  paste0(dout, "/orthogroups_shared_with_dolo.png"), units = "cm", 
  width = 17.4, height = 40
)

#!/usr/bin/env Rscript

# dependencies: tidyverse v1.3.0, tidygenomes v0.1.3, ggtree v2.0.2, 
# phangorn v2.5.5

library(tidyverse)
library(tidygenomes)
library(ggtree)

fin_tree <- "../../results/dpigrum/tree/dpigrum.treefile"
fin_gtdb <- "../../results/dpigrum/gtdb_metadata.csv"
fin_nayfach <- "../../results/dpigrum/nayfach_metadata.csv"
fin_strains <- "../../data/strains_isolation_sources.csv"
dout <- "../../results/dpigrum"

# create output folder if it doesn't exist
if (! dir.exists(dout)) dir.create(dout)

# read tree and midpoint root
tree_raw <- ape::read.tree(fin_tree)
tree <- phangorn::midpoint(tree_raw)

# read and combine genome metadata
genomes_gtdb <- 
  fin_gtdb %>%
  read_csv(col_types = cols()) %>%
  transmute(
    genome = ncbi_genbank_assembly_accession, strain = ncbi_strain_identifiers,
    source = "gtdb", completeness = checkm_completeness, protein_count
  ) 
genomes_nayfach <- 
  fin_nayfach %>%
  read_csv(col_types = cols()) %>%
  transmute(
    genome = genome_id, strain = genome_id, source = "nayfach", completeness
  ) 
strains <- fin_strains %>% read_csv(col_names = cols())
genomes <-
  bind_rows(genomes_gtdb, genomes_nayfach) %>%
  add_row(genome = "AMBR12", strain = "AMBR12", source = "isolate") %>%
  left_join(strains, by = "strain") %>%
  mutate(disease = str_detect(strain, "KPL|ATCC"))

# write combined genome metadata
genomes %>% write_csv(paste0(dout, "/genomes_metadata.csv"))

# prepare tidygenomes object
dpigrum <-
  as_tidygenomes(tree) %>%
  modify_at("genomes", left_join, genomes, by = "genome") %>%
  modify_at(
    "nodes", mutate, 
    support_sh = node_label %>% str_extract("^[0-9]+") %>% as.double(), 
    support_bs = node_label %>% str_extract("[0-9]+$") %>% as.double(),
    trustworthy = support_sh >= 80 & support_bs >= 95
  ) 

# visualize tree
dpigrum %>%
  modify_at(
    "genomes", mutate, 
    fontface = if_else(disease, "plain", "bold"),
    strain = str_remove(strain, "_CDC.*$"),
    tmp = if_else(strain %in% c("AMBR11", "AMBR12"), " *", ""),
    strain = str_c(strain, tmp, sep = "")
  ) %>%
  ggtree_augmented(layout = "rectangular", size = 1, col = "grey") +
  geom_tiplab(
    aes(label = strain, fontface = fontface), size = 4, 
    align = T, linesize = 0.2, offset = 0.002
  ) + 
  geom_point(aes(shape = trustworthy), size = 3) +
  geom_tippoint(aes(col = body_site), size = 4) +
  scale_color_brewer(palette = "Paired", name = "body site", na.value = "grey40") +
  scale_shape_manual(values = c("TRUE" = 16, "FALSE" = 1), guide = F) +
  xlim(c(0, 0.036)) +
  theme(legend.position = "right")
ggsave(
  paste0(dout, "/tree_dpigrum.png"), units = "cm", width = 16, 
  height = 14
)

# visualize tree (no branch support)
dpigrum %>%
  modify_at(
    "genomes", mutate, 
    fontface = if_else(strain %in% c("AMBR11", "AMBR12"), "bold", "plain"),
    strain = str_remove(strain, "_CDC.*$")
  ) %>%
  ggtree_augmented(layout = "rectangular", size = 1, col = "grey") +
  geom_tiplab(
    aes(label = strain, fontface = fontface), size = 4, 
    align = T, linesize = 0.2, offset = 0.002
  ) + 
  geom_tippoint(aes(col = body_site, shape = disease), size = 4) +
  scale_color_brewer(palette = "Paired", name = "body site", na.value = "grey40") +
  xlim(c(0, 0.034)) +
  theme(legend.position = "right") +
  guides(shape = guide_legend(title = "disease-associated"))
ggsave(
  paste0(dout, "/tree_dpigrum_nosupport.png"), units = "cm", width = 16, 
  height = 14
)

# visualize genome size ordered by tree
tips_ordered <-
  dpigrum$tree %>%
  {
    tip_ixs_orderd <- .$edge[.$edge[, 2] <= length(.$tip.label), 2]
    .$tip.label[tip_ixs_orderd]
  }
dpigrum$genomes %>%
  filter(source == "gtdb") %>%
  mutate(ambr11 = if_else(strain == "AMBR11", "AMBR11", "other")) %>%
  mutate(ambr11 = factor(ambr11, levels = c("other", "AMBR11"))) %>%
  mutate(node_fct = factor(node, levels = tips_ordered)) %>%
  arrange(node_fct) %>%
  mutate(strain_fct = factor(strain, levels = strain)) %>%
  ggplot(
    aes(x = strain_fct, y = protein_count, fill = ambr11)
  ) +
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
dpigrum$genomes %>%
  filter(source == "gtdb") %>%
  mutate(
    ambr11 = 
      if_else(strain == "AMBR11", "AMBR11", "other")
  ) %>%
  mutate(ambr11 = factor(ambr11, levels = c("other", "AMBR11"))) %>%
  arrange(protein_count) %>%
  mutate(
    strain_fct = 
      factor(strain, levels = strain)
  ) %>%
  ggplot(
    aes(x = strain_fct, y = protein_count, fill = ambr11)
  ) +
  geom_col() +
  scale_fill_brewer(palette = "Paired") +
  theme_bw() +
  theme(legend.position = "bottom") +
  xlab("") +
  ylab("# proteins") +
  coord_flip()
ggsave(
  paste0(dout, "/protein_count_increasing.png"), units = "cm", width = 17.4, 
  height = 40
)

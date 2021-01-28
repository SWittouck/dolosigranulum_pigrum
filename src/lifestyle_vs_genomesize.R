library(tidyverse)

# get genome size of best quality genome per GTDB species
genomes <-
  "../data/gtdb_r95_metadata_lactobacillales.tsv" %>%
  read_tsv(col_types = cols()) %>%
  mutate(species = str_extract(gtdb_taxonomy, "(?<=s__)[^;]+")) %>%
  group_by(species) %>%
  mutate(quality = checkm_completeness - checkm_contamination) %>%
  arrange(desc(quality)) %>%
  slice(1) %>%
  ungroup() %>%
  select(species, genome_size)

# read species with lifestyles (zheng2020)
species_zheng <-
  "../data/zheng2020_table_S1_corrected.xlsx" %>%
  readxl::read_excel() %>%
  select(
    species = `proposed new species name`, lifestyle_zheng = lifestyle
  ) %>%
  mutate(species = str_extract(species, "^[^ ]+ [^ ]+")) %>%
  mutate(lifestyle_zheng = str_to_lower(lifestyle_zheng)) %>%
  filter(! is.na(lifestyle_zheng), lifestyle_zheng != "unknown") %>%
  distinct()

# visualize Zheng2020 lifestyle vs genome size
genomes %>%
  left_join(species_zheng, by = "species") %>%
  select(species, genome_size, lifestyle_zheng) %>%
  filter(! is.na(lifestyle_zheng)) %>%
  arrange(genome_size) %>%
  mutate(species_fct = factor(species, levels = species,)) %>%
  ggplot(aes(x = species_fct, y = genome_size, fill = lifestyle_zheng)) +
  geom_col() +
  scale_fill_brewer(palette = "Paired") + 
  coord_flip() +
  theme_bw() 
ggsave(
  "../results/lifestyle_vs_genomesize.png", units = "cm", width = 16, 
  height = 50
)

library(tidyverse)
library(tidyamplicons)

fin <- "../../results/emp/emp_tidyamplicons.rda"
dout <- "../../results/emp_figures"

load(fin)

emp_dolosi <-
  emp %>%
  aggregate_taxa(rank = "genus") %>%
  add_rel_abundance() %>%
  filter_taxa(genus %in% c("D_5__Dolosigranulum"))

samples_dolosiabun <- 
  emp_dolosi$samples %>%
  left_join(emp_dolosi$abundances, by = "sample_id") %>%
  replace_na(list(rel_abundance = 0))

samples_dolosiabun %>%
  mutate(dolosigranulum_present = rel_abundance != 0) %>%
  ggplot(aes(x = empo_3, fill = dolosigranulum_present)) +
  geom_bar() +
  xlab("EMP ontology level 3") +
  scale_fill_manual(values = c("FALSE" = "#bdbdbd", "TRUE" = "#636363")) +
  coord_flip() +
  theme_bw() +
  theme(legend.position = "bottom") 
ggsave(
  paste0(dout, "/dolosigranulum_occurrence.png"), units = "cm", width = 15, 
  height = 20
)

samples_dolosiabun %>%
  ggplot(aes(x = rel_abundance)) +
  geom_density() +
  geom_rug() + 
  facet_wrap(~ empo_3, ncol = 2, scales = "free_y") +
  theme_bw() +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  )
ggsave(
  paste0(dout, "/dolosigranulum_abundance.png"), units = "cm", width = 20, 
  height = 30
)

samples_animals <-
  samples_dolosiabun %>%
  select(empo_2, host_scientific_name, rel_abundance) %>%
  filter(empo_2 == "Animal", ! is.na(host_scientific_name)) %>%
  add_count(host_scientific_name)%>%
  filter(n >= 10) 

samples_animals %>%
  select(host_scientific_name) %>%
  count(host_scientific_name, name = "n_samples") %>%
  write_csv(paste0(dout, "/animal_host_counts.csv"))

animals <- 
  samples_animals %>%
  group_by(host_scientific_name) %>%
  summarize(frac_with_dolosis = sum(rel_abundance > 0) / n())
  
samples_animals %>%
  select(host_scientific_name, rel_abundance) %>%
  filter(! is.na(host_scientific_name)) %>%
  nest(rel_abundance) %>%
  mutate(mean_ab = map_dbl(data, ~ mean(.[[1]]))) %>%
  mutate(
    host_scientific_name_fct = fct_reorder(host_scientific_name, mean_ab)
  ) %>%
  unnest() %>%
  ggplot(aes(x = host_scientific_name, y = rel_abundance)) +
  geom_point(alpha = 0.4) +
  geom_col(data = animals, aes(y = frac_with_dolosis), alpha = 0.3) +
  xlab("host scientific name") + 
  ylab("relative abundance") + 
  coord_flip() +
  theme_bw()
ggsave(
  paste0(dout, "/dolosigranulum_in_animals.png"), units = "cm", width = 10, 
  height = 20
)  

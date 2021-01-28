pivot_sparser <- function(x, pos) {
  
  x %>%
    gather(key = "sample", value = "abundance", - `#OTU ID`) %>%
    filter(abundance != 0)
  
}

samples_onetaxon <- function(ta, taxon) {
  
  taxon <- rlang::enquo(taxon)
  
  ta %>%
    mutate_taxa(of_interest = !! taxon) %>%
    set_rank_names(c("of_interest")) %>%
    aggregate_taxa(rank = "of_interest") %>%
    add_rel_abundance() %>%
    filter_taxa(of_interest == T) %>%
    {left_join(.$samples, .$abundances)} %>%
    replace_na(list(rel_abundance = 0))
  
}

# barplot + scatterplot to show prevalence and abundance per host
hostplot <- function(samples) {
  
  samples <-
    samples %>%
    select(host_scientific_name, rel_abundance) %>%
    filter(! is.na(host_scientific_name)) %>%
    add_count(host_scientific_name)%>%
    filter(n >= 10) 
  
  animals <- 
    samples %>%
    group_by(host_scientific_name) %>%
    summarize(frac = sum(rel_abundance > 0) / n())
  
  samples %>%
    select(host_scientific_name, rel_abundance) %>%
    nest(rel_abundance) %>%
    mutate(mean_ab = map_dbl(data, ~ mean(.[[1]]))) %>%
    mutate(
      host_scientific_name_fct = fct_reorder(host_scientific_name, mean_ab)
    ) %>%
    unnest() %>%
    ggplot(aes(x = host_scientific_name, y = rel_abundance)) +
    geom_point(alpha = 0.4) +
    geom_col(data = animals, aes(y = frac), alpha = 0.3) +
    ylim(c(0, 1)) +
    coord_flip() +
    theme_bw()
  
}

# heatmap showing abundance/prevalence of taxa per host organism
hostmap <- function(ta, value = "mean_rel_abundance") {
  
  ta <- 
    ta %>%
    add_rel_abundance() %>%
    filter_taxa(family != "non-lacto") %>%
    modify_at("taxa", replace_na, list(genus = "other"))
  
  hosts <-
    ta$samples %>%
    count(host_scientific_name, name = "n_samples") 
  
  abundances <-
    ta$abundances %>%
    left_join(ta$samples, by = "sample_id") %>%
    left_join(ta$taxa, by = "taxon_id") %>%
    filter(! is.na(host_scientific_name)) %>%
    group_by(genus, host_scientific_name) %>%
    summarize(
      total_rel_abundance = sum(rel_abundance), 
      prevalence_count = n()
    ) %>%
    ungroup() %>%
    left_join(hosts, by = "host_scientific_name") %>%
    filter(n_samples >= 10) %>%
    mutate(
      mean_rel_abundance = total_rel_abundance / n_samples,
      prevalence = prevalence_count / n_samples
    )
  
  matrix <-
    abundances %>%
    select(genus, host_scientific_name, !! value) %>%
    spread(key = genus, value = !! value, fill = 0) %>%
    `class<-`("data.frame") %>%
    `rownames<-`(.$host_scientific_name) %>%
    select(- host_scientific_name) %>%
    as.matrix()
  
  host_labels <-
    matrix %>%
    dist(method = "minkowski", p = 3) %>%
    hclust() %>%
    {.$labels[.$order]}
  
  genus_labels <-
    matrix %>%
    t() %>%
    dist(method = "minkowski", p = 3) %>%
    hclust() %>%
    {.$labels[.$order]}
  
  abundances %>%
    mutate_at("host_scientific_name", factor, levels = host_labels) %>%
    mutate_at("genus", factor, levels = genus_labels) %>%
    mutate(fill = log10(!! sym(value))) %>%
    complete(genus, host_scientific_name) %>%
    ggplot(aes(x = genus, y = host_scientific_name, fill = fill)) +
    geom_tile() +
    geom_text(
      aes(label = round(!! sym(value) * 100, 2)), col = "black", size = 1.5
    ) +
    theme(
      text = element_text(size = 6), 
      axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
      legend.position = "none"
    )
  
}

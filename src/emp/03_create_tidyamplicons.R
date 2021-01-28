#!/usr/bin/env Rscript

library(tidyverse)
library(tidyamplicons)

source("functions.R")

din <- "../../results/emp"
dout <- "../../results/emp"

abundances <- 
  read_tsv_chunked(
    file = paste0(din, "/abundances.tsv"), 
    callback = DataFrameCallback$new(pivot_sparser),
    skip = 1 
  ) %>%
  rename(taxon = `#OTU ID`)

samples <- 
  read_tsv(paste0(din, "/samples.tsv"), col_types = cols(.default = "c")) %>%
  select(sample = `#SampleID`, contains("empo"), host_scientific_name)

taxa <-
  read_csv(paste0(din, "/taxa.csv"), col_types = cols(.default = "c")) %>%
  set_names(c(
    "taxon", "domain", "phylum", "class", "order", "family", "genus", "species"
  ))

emp <- 
  make_tidyamplicons(
    abundances = abundances,
    samples = samples, 
    taxa = taxa,
    sample_name = sample,
    taxon_name = taxon
  )
save(emp, file = str_c(dout, "/emp_tidyamplicons.rda"))

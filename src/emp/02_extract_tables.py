#!/usr/bin/env python3

import biom
import os

fin_biom = "../../data/emp_cr_silva_16S_123.subset/emp_cr_silva_16S_123.subset_10k.rare_10000.biom"
dout = "../../results/emp"

b = biom.load_table(fin_biom)

with open(dout + "/abundances.tsv", "w") as hout:
  hout.write(b.to_tsv())

taxa = b.metadata_to_dataframe("observation")
taxa.to_csv(dout + "/taxa.csv")

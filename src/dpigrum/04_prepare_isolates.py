#!/usr/bin/env python3

# This script prepares the genomes of the isolates by making their contig names
# unique between genomes.

# dependencies: python3, biopython

import gzip
import os
import re

from Bio import SeqIO, SeqRecord

din_isolates = "../../data/genomes_dpigrum_isolates"
dout_isolates = "../../results/dpigrum/genomes_isolates"

try:
    os.mkdir(dout_isolates)
except FileExistsError:
    pass

for file in os.listdir(din_isolates):
    fin_isolate = din_isolates + "/" + file
    fout_isolate = dout_isolates + "/" + file
    genome = re.findall(r"([^/]+).fna.gz", fin_isolate)[0]
    print(genome)
    with gzip.open(fin_isolate, "rt") as hin_isolate:
        with gzip.open(fout_isolate, "at") as hout_isolate:
            for record in SeqIO.parse(hin_isolate, "fasta"):
                record.id = genome + "_" + record.id
                SeqIO.write(record, hout_isolate, "fasta")

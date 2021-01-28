# Dolosigranulum pigrum

This repository contains scripts to analyze the ecology and evolution of the species Dolosigranulum pigrum. A publication with the results of these analyses is currently under review. 

## Dependencies

Software:

* Progenomics 13b9be1
* Proclasp v1.0
* Prodigal v2.6.3
* trimal 1.4.rev15
* IQ-TREE v1.6.12

R and R packages:

* R v 3.6.3
* tidyverse v1.3.0
* tidygenomes v0.1.3
* ggtree v2.0.2
* phangorn v2.5.5

## Data

emp_cr_silva_16S_123.subset

* dataset from release 1 of the [Earth Microbiome Project](https://earthmicrobiome.org/)
* downloaded by the script src/emp/01_download_data.sh

genomes_dpigrum_isolates

* genomes of the following isolates of the [Lebeer Lab](https://lebeerlab.com/): AMBR12

genomes_dpigrum_nayfach

* all D. pigrum MAGs reconstructed by [Nayfach et al. (2020)](https://doi.org/10.1038/s41587-020-0718-6)
* downloaded by the script src/dpigrum/03_download_genomes.sh

genomes_dpigrum_ncbi

* all D. pigrum genomes available in the GTDB, downloaded from the NCBI
* downloaded by the script src/dpigrum/03_download_genomes.sh

genomes_lactobacillales_ncbi

* a selection of one high-quality genome per species (for Carnobacteriaceae) or per genus (for non-Carnobacteriaceae) downloaded from the NCBI
* downloaded by the script src/lactobacillales/03_download_genomes.sh

41587_2020_718_MOESM3_ESM.xlsx

* very extensive metadata for all MAGs reconstructed by Nayfach et al. (2020)
* downloaded from https://doi.org/10.1038/s41587-020-0718-6, Supplementary Information

gtdb_r95_metadata_dpigrum.tsv

* metadata of all Dolosigranulum pigrum genomes that are in release 95 of the GTDB
* downloaded by the script src/dpigrum/01_download_metadata.R

gtdb_r95_metadata_lactobacillales.tsv

* metadata of all Lactobacillales genomes that are in release 95 of the GTDB
* downloaded by the script src/lactobacillales/01_download_metadata.R

nayfach2020_metadata_dpigrum.tsv 

* metadata of all D. pigrum MAGs reconstructed by Nayfach et al. (2020)
* downloaded by the script src/dpigrum/01_download_metadata.R

strains_isolation_sources.xlsx

* data on the isolation sources of all D. pigrum strains included
* health status of Nayfach et al. MAGs: looked up the samples IDs here: <https://gold.jgi.doe.gov/biosamples>

zheng2020_table_S1_corrected.xlsx

* metadata for all Lactobacillaceae species described by [Zheng et al. (2020, IJSEM)](https://doi.org/10.1099/ijsem.0.004107)
* downloaded from <https://www.microbiologyresearch.org/content/journal/ijsem/10.1099/ijsem.0.004107#supplementary_data>
* corrections: 
    * deleted row 158 (exact duplicate of row 149; Lactobacillus mulieris)
    * cell C53: changed to "Lactobacillus algidus" (added genus name)
    * cell O53: changed to "Dellaglioa algida" (added genus name)
    * cell C245: changed to "Lactobacillus aquaticus" (removed the single quote)
    * cell O324: changed to "Pediococcus acidilactici" (added genus name)
    * cells C300 - C304: fixed double spaces
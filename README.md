# Sparse Spatial P-Rep MET Scenario Builder
This repository provides a semi-automated, reproducible Excel-R workflow for designing sparse spatial partially replicated (p-rep) multi-environment trials (METs) randomizations with controlled pedigree-aware connectivity and genetic diversity.

The repository is released as a public good to support transparent, citable, and reproducible trial design in breeding and biometrics research.

## Overview
* __Scenario Builder (Excel):__ Defines trial structure and generates a customized R script for spatial randomization.
* __Spatial randomization (R / DiGGer):__ Produces near-optimal field layouts and field books for each location.
* __Pedigree-aware entry allocation (R):__ Allocates entries under seed-availability constraints while maximizing genetic diversity.

## Workflow

### 1. Configure Trial Scenario
Edit input parameters in cells B1–B6 of the Scenario Builder Excel file. 

Two key tuning parameters are:
* __B4:__ Number of entries shared across locations.
* __B5:__ Number of partially replicated test entries per location.

> _The resulting total number of plots per location is automatically calculated in cell __B11__. Users should iteratively adjust __B4__ and __B5__ until the desired trial size and balance are achieved._

> __Design Rules of Thumb__
> * Replicated entries should account for at least 15% of the total entries in each location (The typical replication ratio is 1:4 as per Cullis et al., 2006).
> * Shared entries across locations should account for at least 15% of the total entries in each location. Research on sparse METs indicates that prediction accuracy and model stability decline significantly when the proportion of common entries falls below 10%. An overlap of 15-20% is generally recommended for reliable connectivity in mixed-model or GP-assisted MET analysis (e.g., Jarquin et al. 2020).

> __References:__
>
> _1. Cullis et al. (2006). On the Design of Early Generation Variety Trials with Correlated Data. Journal of Agricultural, Biological, and Environmental Statistics, 11(4), 381–393._
> >
> _2. Jarquin et al. (2020). Genomic Prediction Enhanced Sparse Testing for Multi-environment Trials. G3: Genes | Genomes | Genetics, 10(8), 2725–2739. https://doi.org/10.1534/g3.120.401349_

### 2. Generate Spatial Design(s)
Generate the required randomization(s) by setting the location ID in cell _B26_ of the Scenario Builder file. Then, copy the script lines from the range _A28:A64_ into your R console and execute the code to produce the corresponding field book and layout using the [DiGGer package](http://nswdpibiom.org/austatgen/software). Please note that this step remains semi-automated for now, but we aim to fully automate it in future.

### 3. Allocate Test Entries
To allocate entries according to the structure defined in the previous Scenario Builder (rows 20-24), run the `Test_entries_allocate.R` script. This script requires two input files: a list of candidate entries (e.g., `FFMPYT-26 Entries.csv`) and a pedigree matrix (e.g., `FFMPYT-26 Pedigree Matrix.csv.gz`).

> ___Note:__ A regular CSV file can be used instead of the compressed .gz version. However, compression typically reduces such file size to less than 1% of the original, which is recommended for handling large pedigree matrices efficiently._

The allocation strategy begins by applying logistical constraints related to seed availability for each category of entry (shared across locations and partially replicated within locations). It then iteratively filters out entries with the highest pedigree similarity in order to retain a core set maximizing genetic diversity.

## Citation
If you use this workflow in your research, please cite the repository as:
```
M. Sanchez Garcia, Z. Kehel, and K. Al-Shamaa. (2026). 
Sparse Spatial P-Rep MET Randomization: An Excel–R Semi-Automated Workflow for Pedigree-Aware Entry Allocation.
GitHub repository. https://github.com/icarda/sparse_prep_design
```

## License
This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.  
You may use, modify, and redistribute this software under the terms of this license. Any derivative work must also be released under GPL-3.0. See the `LICENSE` file for the full license text.


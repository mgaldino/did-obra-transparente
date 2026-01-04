# Obra Transparente DiD Analysis

Replication package for "The Civil Society Organizations effect: A mixed-methods analysis of bottom-up approaches in Brazilian public policy" (Galdino et al., 2024).

## Overview

This repository contains code and data to replicate the quantitative analysis of the impact of the **Obra Transparente** project on public school and nursery construction completion rates in Brazil.

The Obra Transparente project was implemented by Transparência Brasil from May 2017 to June 2019, engaging 21 local Civil Society Organizations (CSOs) to monitor construction works in municipalities across South and Southeast Brazil.

## Key Findings

- **Treatment Effect**: Municipalities with CSO monitoring showed a 6.2 percentage point increase in construction completion probability (p < 0.05)
- **Dynamic Effects**: The treatment effect grows over time, reaching 14.8 p.p. by the second period after treatment
- **Parallel Trends**: Pre-treatment coefficients are close to zero, supporting the parallel trends assumption

## Quick Start

```r
# Install required packages
install.packages(c("tidyverse", "here", "fixest", "knitr"))

# Run complete replication
source(here::here("code", "99_run_all.R"))
```

## Structure

```
├── code/               # R scripts
│   ├── 01_load_data.R
│   ├── 02_create_analysis_data.R
│   ├── 03_descriptive_stats.R
│   ├── 04_did_analysis.R
│   ├── 05_figures.R
│   └── 99_run_all.R
├── data/
│   ├── raw/            # Input data
│   ├── processed/      # Generated data
│   └── metadata/       # Codebook
├── output/
│   ├── tables/         # Generated tables
│   └── figures/        # Generated figures
├── REPLICATION.md      # Detailed replication guide
└── README.md           # This file
```

## Data

The analysis uses administrative data from SIMEC (Sistema Integrado de Monitoramento, Execução e Controle) and municipal characteristics from IPEA. See `data/metadata/CODEBOOK.md` for variable descriptions.

## Requirements

- R >= 4.0
- Packages: tidyverse, here, fixest, knitr

## Citation

```bibtex
@article{galdino2024cso,
  title={The Civil Society Organizations effect: A mixed-methods analysis of bottom-up approaches in Brazilian public policy},
  author={Galdino, Manoel and Sakai, Juliana and Mondo, Bianca Vaz and Paiva, Natália},
  year={2024}
}
```

## License

MIT License. See `LICENSE` for details.

## Contact

Manoel Galdino - mgaldino@usp.br

# Obra Transparente DiD Analysis

Replication package for "The Civil Society Organizations effect: A mixed-methods analysis of bottom-up approaches in Brazilian public policy" (Galdino et al., 2024).

## Overview

This repository contains code and data to replicate the quantitative analysis of the impact of the **Obra Transparente** project on public school and nursery construction completion rates in Brazil.

The Obra Transparente project was implemented by Transparência Brasil from May 2017 to June 2019, engaging 21 local Civil Society Organizations (CSOs) to monitor construction works in municipalities across South and Southeast Brazil.

## Key Findings

- **Treatment Effect**: Municipalities with CSO monitoring showed a 6.5 percentage point increase in construction completion probability (p < 0.05)
- **Dynamic Effects**: The treatment effect grows over time, reaching 15.8 p.p. by period 5 (October 2023)
- **Parallel Trends**: Pre-treatment coefficients are close to zero, supporting the parallel trends assumption

## Quick Start

```r
# Install required packages
install.packages(c("tidyverse", "here", "fixest", "readxl", "janitor", "data.table"))

# Run complete replication
source(here::here("code", "99_run_all.R"))
```

## Structure

```
├── code/
│   ├── 00a_download_data.R          # Download SIMEC snapshots from GitHub
│   ├── 00b_process_simec_snapshots.R # Process raw snapshots (optional)
│   ├── 01_did_analysis_5periods.R   # Main analysis: DiD + Event Study
│   └── 99_run_all.R                 # Master script (run this)
├── data/
│   ├── raw/simec_snapshots/         # SIMEC CSV snapshots
│   ├── processed/                   # Generated panel data
│   └── metadata/                    # Codebook
├── original/data/                   # Original .Rdata files
├── output/
│   ├── tables/                      # Generated tables (.tex, .csv)
│   └── figures/                     # Generated figures (.png, .pdf)
├── notes/                           # Documentation and validation
├── REPLICATION.md                   # Detailed replication guide
└── README.md                        # This file
```

## Data

The analysis uses administrative data from SIMEC (Sistema Integrado de Monitoramento, Execução e Controle) and municipal characteristics from IPEA. See `data/metadata/CODEBOOK.md` for variable descriptions.

## Requirements

- R >= 4.0
- Packages: tidyverse, here, fixest, readxl, janitor, data.table

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

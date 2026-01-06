# Guia de Replicação

## Obra Transparente DiD Analysis

**Paper**: "The Civil Society Organizations effect: A mixed-methods analysis of bottom-up approaches in Brazilian public policy" (Galdino et al., 2024)

**Última atualização**: 2026-01-05

---

## Requisitos

### Software

- **R** >= 4.0.0
- **RStudio** (recomendado, mas opcional)
- **Git** (para download automático dos dados)

### Pacotes R

Instale os pacotes necessários executando:

```r
install.packages(c(
  "tidyverse",
  "here",
  "fixest",
  "readxl",
  "janitor",
  "data.table"
))
```

**Lista de pacotes utilizados**:

| Pacote | Versão Testada | Uso |
|--------|----------------|-----|
| tidyverse | 2.0.0 | Manipulação de dados |
| here | 1.0.1 | Caminhos relativos |
| fixest | 0.12.1 | Modelos DiD e Event Study |
| readxl | 1.4.3 | Leitura de Excel |
| janitor | 2.2.0 | Limpeza de dados |
| data.table | 1.17.0 | Leitura rápida de CSVs |

---

## Estrutura do Projeto

```
did-obra-transparente/
├── REPLICATION.md          # Este arquivo
├── README.md               # Visão geral do projeto
├── code/
│   ├── 00a_download_data.R         # Download de dados GitHub
│   ├── 00b_process_simec_snapshots.R  # Processamento (opcional)
│   ├── 01_did_analysis_5periods.R  # Análise principal
│   └── 99_run_all.R                # Master script
├── data/
│   ├── raw/simec_snapshots/        # Snapshots SIMEC (CSV)
│   ├── processed/                  # Dados processados (gerados)
│   └── metadata/CODEBOOK.md        # Documentação dos dados
├── original/data/                  # Arquivos .Rdata originais
└── notes/                          # Documentação adicional
```

---

## Fontes de Dados (Reproduzíveis)

Esta análise usa **apenas dados de fontes conhecidas e rastreáveis**:

| Arquivo | Período | Fonte | Origem |
|---------|---------|-------|--------|
| `obras_inicio_projeto.Rdata` | 1 (Mai/2017) | Transparência Brasil | `original/data/` |
| `obras_08032018.csv` | 2 (Mar/2018) | GitHub TB | Download automático |
| `obras_upload28092018.csv` | 3 (Set/2018) | GitHub TB | Download automático |
| `obras_fim_seg_fase.Rdata` | 4 (Ago/2019) | Transparência Brasil | `original/data/` |
| `simec 25-10-23 - simec.csv` | 5 (Out/2023) | Transparência Brasil | `original/data/` |
| `situacao obras_atual.xlsx` | - | Transparência Brasil | Lista de obras tratadas |

**Repositórios GitHub**:
- https://github.com/Transparencia-Brasil/avaliacao_impacto_092019
- https://github.com/Transparencia-Brasil/campanha_TDP_2018

---

## Replicação Passo-a-Passo

### 1. Preparar Ambiente

```bash
# Clonar o repositório (ou descompactar o pacote de replicação)
git clone [URL_DO_REPOSITORIO]
cd did-obra-transparente
```

```r
# Verificar working directory em R
library(here)
here()  # Deve mostrar o caminho do projeto
```

### 2. Verificar Dados Necessários

Os seguintes arquivos devem existir em `original/data/`:
- `obras_inicio_projeto.Rdata`
- `obras_fim_seg_fase.Rdata`
- `situacao obras_atual.xlsx`
- `simec 25-10-23 - simec.csv`

### 3. Executar Pipeline Completo

**Opção A: Via R/RStudio**
```r
source(here::here("code", "99_run_all.R"))
```

**Opção B: Via linha de comando**
```bash
Rscript code/99_run_all.R
```

O script irá:
1. Verificar dados necessários
2. Baixar snapshots SIMEC do GitHub (se necessário)
3. Criar painel balanceado de 5 períodos
4. Executar análise DiD estático
5. Executar event study
6. Salvar resultados

### 4. Verificar Outputs

Após execução, os seguintes arquivos serão gerados em `data/processed/`:

| Arquivo | Descrição |
|---------|-----------|
| `did_panel_5periods.rds` | Painel balanceado (22.616 obs) |
| `did_results_5periods.rds` | Resultados completos (modelos, coeficientes) |

---

## Resultados Esperados

### Dados

- **4.664 obras** em 2.050 municípios
- **226 obras** em 21 municípios tratados
- 5 períodos: Mai/17, Mar/18, Set/18, Ago/19, Out/23

### Taxas de Conclusão

| Período | Controle | Tratados |
|:-------:|:--------:|:--------:|
| 1 (Mai/17) | 49.4% | 28.8% |
| 2 (Mar/18) | 54.4% | 32.7% |
| 3 (Set/18) | 57.4% | 36.9% |
| 4 (Ago/19) | 60.0% | 42.2% |
| 5 (Out/23) | 86.5% | 80.4% |

### DiD Estático (TWFE)

| ATT | SE | IC 95% | p-value |
|:---:|:--:|:------:|:-------:|
| **+0.065** | 0.029 | [0.008, 0.122] | **0.026** |

**Interpretação**: O projeto Obra Transparente aumenta a probabilidade de conclusão em ~6.5 pontos percentuais.

### Event Study

| Período Relativo | Coeficiente | SE | p-value |
|:----------------:|:-----------:|:--:|:-------:|
| t = -2 | +0.011 | 0.013 | 0.379 |
| t = -1 | 0.000 | (ref) | - |
| t = 0 | +0.015 | 0.022 | 0.493 |
| t = +1 | +0.041 | 0.031 | 0.183 |
| t = +2 | **+0.158** | 0.073 | **0.032** |

**Interpretação**:
- Tendências paralelas OK (coef. t=-2 não significativo)
- Efeito cresce ao longo do tempo
- Efeito de longo prazo (t=+2) significativo: +15.8 p.p.

---

## Tempo de Execução

O pipeline completo leva aproximadamente **5-10 segundos**.

---

## Solução de Problemas

### Erro: "Working directory incorreto"

```r
setwd("/caminho/para/did-obra-transparente")
```

### Erro: "Arquivos originais faltando"

Verifique se os arquivos `.Rdata` e `.xlsx` estão em `original/data/`.

### Erro: "Não foi possível baixar snapshots"

Execute manualmente:
```r
source(here::here("code", "00a_download_data.R"))
```

Ou baixe os CSVs manualmente de:
- https://github.com/Transparencia-Brasil/avaliacao_impacto_092019/tree/master/Bancos/Planilhas%20SIMEC

---

## Contato

- **Autor**: Manoel Galdino (mgaldino@usp.br)
- **Transparência Brasil**: https://www.transparencia.org.br/

---

## Licença

Este código é disponibilizado sob a licença MIT.

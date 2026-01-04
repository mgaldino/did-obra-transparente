# Guia de Replicação

## Obra Transparente DiD Analysis

**Paper**: "The Civil Society Organizations effect: A mixed-methods analysis of bottom-up approaches in Brazilian public policy" (Galdino et al., 2024)

**Última atualização**: 2026-01-04

---

## Requisitos

### Software

- **R** >= 4.0.0
- **RStudio** (recomendado, mas opcional)

### Pacotes R

Instale os pacotes necessários executando:

```r
install.packages(c(
  "tidyverse",
  "here",
  "fixest",
  "knitr"
))
```

**Lista de pacotes utilizados**:

| Pacote | Versão Testada | Uso |
|--------|----------------|-----|
| tidyverse | 2.0.0 | Manipulação de dados |
| here | 1.0.1 | Caminhos relativos |
| fixest | 0.11.2 | Modelos DiD e Event Study |
| knitr | 1.45 | Geração de tabelas |

---

## Estrutura do Projeto

```
did-obra-transparente/
├── REPLICATION.md          # Este arquivo
├── README.md               # Visão geral do projeto
├── CLAUDE.md               # Instruções de desenvolvimento
├── code/                   # Scripts R
│   ├── 01_load_data.R
│   ├── 02_create_analysis_data.R
│   ├── 03_descriptive_stats.R
│   ├── 04_did_analysis.R
│   ├── 05_figures.R
│   └── 99_run_all.R        # Master script
├── data/
│   ├── raw/                # Dados brutos
│   ├── processed/          # Dados processados (gerados)
│   └── metadata/           # Codebook e inventário
├── output/
│   ├── tables/             # Tabelas (geradas)
│   └── figures/            # Figuras (geradas)
├── notes/                  # Documentação
└── original/               # Materiais originais (referência)
```

---

## Dados

### Dados Brutos (`data/raw/`)

Os seguintes arquivos são necessários para replicação:

| Arquivo | Descrição | Fonte |
|---------|-----------|-------|
| `did_panel.rds` | Painel de obras para DiD | Transparência Brasil |
| `municipal_covariates.rds` | Covariáveis municipais | IPEA/IBGE |
| `simec_2017_08.Rdata` | Snapshot SIMEC ago/2017 | SIMEC/FNDE |
| `simec_2019_08.Rdata` | Snapshot SIMEC ago/2019 | SIMEC/FNDE |
| `treated_municipalities.csv` | Lista dos 21 municípios tratados | Transparência Brasil |

**Nota**: Os dados foram pré-processados pela equipe da Transparência Brasil. Consulte `data/metadata/CODEBOOK.md` para descrição completa das variáveis.

### Dados Processados

Todos os dados em `data/processed/` são gerados automaticamente pelos scripts.

---

## Replicação Passo-a-Passo

### 1. Preparar Ambiente

```r
# Abrir R ou RStudio
# Navegar até a pasta do projeto
setwd("/caminho/para/did-obra-transparente")

# Verificar working directory
library(here)
here()  # Deve mostrar o caminho do projeto
```

### 2. Executar Pipeline Completo

**Opção A: Via R/RStudio**
```r
source(here::here("code", "99_run_all.R"))
```

**Opção B: Via linha de comando**
```bash
cd /caminho/para/did-obra-transparente
Rscript code/99_run_all.R
```

### 3. Verificar Outputs

Após execução bem-sucedida, os seguintes arquivos serão gerados:

**Tabelas** (`output/tables/`):
- `table1_summary_stats.csv` - Summary statistics
- `table2_completion_rates.csv` - Completion rates
- `table3_did_static.csv` - Resultados DiD estático
- `table4_event_study.csv` - Resultados event study

**Figuras** (`output/figures/`):
- `fig1_event_study.png` - Event study plot
- `fig2_completion_trends.png` - Tendências de conclusão

---

## Execução Individual de Scripts

Se preferir executar os scripts individualmente:

```r
library(here)

# 1. Carregar dados
source(here("code", "01_load_data.R"))

# 2. Criar datasets de análise
source(here("code", "02_create_analysis_data.R"))

# 3. Estatísticas descritivas
source(here("code", "03_descriptive_stats.R"))

# 4. Análise DiD
source(here("code", "04_did_analysis.R"))

# 5. Figuras
source(here("code", "05_figures.R"))
```

**Importante**: Os scripts devem ser executados na ordem acima, pois cada um depende dos outputs do anterior.

---

## Resultados Esperados

### Table 2: Completion Rates

| Grupo | Ago 2017 | Ago 2019 |
|-------|----------|----------|
| Tratados | 29% | 42% |
| Controle | 49% | 59% |

### DiD Estático

- **ATT**: 0.062 (SE = 0.031)
- **Interpretação**: Tratamento aumenta probabilidade de conclusão em ~6 p.p.
- **Significância**: p < 0.05

### Event Study

| Período | Coeficiente | SE |
|---------|-------------|-----|
| -2 | -0.006 | 0.042 |
| -1 | ref | - |
| 0 | 0.004 | 0.025 |
| +1 | 0.026 | 0.031 |
| +2 | 0.148* | 0.062 |

---

## Tempo de Execução

O pipeline completo leva aproximadamente **2-5 segundos** em um computador moderno.

---

## Solução de Problemas

### Erro: "Working directory incorreto"

Certifique-se de estar na pasta raiz do projeto:
```r
setwd("/caminho/para/did-obra-transparente")
```

### Erro: "Arquivo não encontrado"

Verifique se todos os arquivos em `data/raw/` existem:
```r
list.files(here::here("data", "raw"))
```

### Erro: "Pacote não encontrado"

Instale o pacote faltante:
```r
install.packages("nome_do_pacote")
```

---

## Contato

Para questões sobre os dados ou código:
- **Autor**: Manoel Galdino (mgaldino@usp.br)
- **Transparência Brasil**: https://www.transparencia.org.br/

---

## Licença

Este código é disponibilizado sob a licença MIT. Consulte o arquivo `LICENSE` para detalhes.

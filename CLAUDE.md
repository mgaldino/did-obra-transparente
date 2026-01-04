# Projeto: Organização e Replicação - Obra Transparente DiD Analysis

## Visão Geral do Projeto

Este projeto tem como objetivo **reorganizar completamente e criar documentação de replicação profissional** para um paper acadêmico existente sobre o impacto de monitoramento por OSCs (Organizações da Sociedade Civil) na conclusão de obras públicas de escolas e creches no Brasil.

**Paper**: "The Civil Society Organizations effect: A mixed-methods analysis of bottom-up approaches in Brazilian public policy" (Galdino et al., 2024)

**Tarefas principais**:
1. Organizar dados dispersos e desorganizados
2. **Reescrever completamente todo o código R** - código atual é de baixa qualidade
3. Criar documentação de replicação que permita submissão do paper
4. Validar que todos os resultados do paper são reproduzíveis

**Localização dos materiais originais**: `~/Documents/DCP/Papers/Obra Transparente/obra_transparente`

## REGRAS DE SEGURANÇA DO SISTEMA DE ARQUIVOS

### Working Directory
- **SEMPRE** trabalhe em: `/Users/manoelgaldino/Documents/DCP/Papers/DiDObraTransparente/did-obra-transparente`
- Verifique com `getwd()` em R ou `pwd` no bash antes de começar
- Use `here::here()` para TODOS os caminhos relativos

### Pasta Original (Somente Leitura)
- Pasta: `~/Documents/DCP/Papers/Obra Transparente/obra_transparente`
- **SOMENTE CÓPIA** - nunca modificar ou deletar
- Use Task 0.2 para copiar para `original/` no projeto
- Depois, trabalhe apenas em `original/` (cópia local)

### Regras Estritas
1. ❌ NUNCA deletar arquivos fora do diretório do projeto
2. ❌ NUNCA modificar `~/Documents/DCP/Papers/Obra Transparente/obra_transparente`
3. ✅ SEMPRE usar caminhos relativos com `here::here()`
4. ✅ SEMPRE confirmar working directory antes de operações destrutivas
5. ✅ Pedir confirmação antes de deletar qualquer arquivo

### Estrutura Esperada
```
/Users/manoelgaldino/Documents/DCP/Papers/DiDObraTransparente/did-obra-transparente/
├── original/          # ← Cópia dos arquivos antigos (somente leitura)
├── code/             # ← Novo código limpo
├── data/             # ← Dados organizados
├── output/           # ← Outputs gerados
└── ...
```
---

## IMPORTANTE: Pontos de Parada e Verificação (🛑)

Ao longo deste projeto, há pontos **OBRIGATÓRIOS DE PARADA E VERIFICAÇÃO** marcados com 🛑. Em cada um desses pontos, você deve:

1. Resumir o que foi completado
2. Apresentar outputs principais para revisão
3. Listar quaisquer problemas ou preocupações
4. **Aguardar aprovação humana antes de prosseguir**

**Não prossiga além de um checkpoint 🛑 sem aprovação explícita.**

---

## Estrutura do Projeto
````
DiDObraTransparente/did-obra-transparente/
├── README.md                      # Visão geral do projeto
├── CLAUDE.md                      # Este arquivo (instruções)
├── REPLICATION.md                 # Guia de replicação detalhado
├── requirements.txt               # Pacotes R necessários
├── original/                      # Materiais originais (referência)
│   ├── code/                     # Scripts R antigos (ruins)
│   ├── data/                     # Dados desorganizados
│   └── notes/                    # Anotações antigas
├── code/                         # Código R NOVO (limpo)
│   ├── functions/                # Funções auxiliares
│   ├── 01_import_simec.R
│   ├── 02_clean_data.R
│   ├── ...
│   └── 99_run_all.R             # Master script
├── data/
│   ├── raw/                      # Dados brutos organizados
│   ├── processed/                # Dados limpos (.rds)
│   └── metadata/                 # Documentação de dados
├── notes/                        # Documentação do projeto
├── output/
│   ├── tables/                   # Tabelas (.tex, .csv)
│   ├── figures/                  # Figuras (.png, .pdf)
│   └── paper/                    # Versões do paper
└── logs/                         # Logs de execução
````

---

## FASE 0: Setup do Projeto e Materiais Originais

### Task 0.1: Criar Estrutura de Diretórios

Criar a estrutura de pastas listada acima.
````r
# Script para criar estrutura
dirs <- c(
  "original/code", "original/data", "original/notes",
  "code/functions",
  "data/raw", "data/processed", "data/metadata",
  "notes",
  "output/tables", "output/figures", "output/paper",
  "logs"
)

for (dir in dirs) {
  dir.create(here::here(dir), recursive = TRUE, showWarnings = FALSE)
}
````

### Task 0.2: Copiar Materiais Originais

Copiar (NÃO mover) arquivos da pasta desorganizada para `original/`:
````bash
# Copiar tudo da pasta antiga para original/
cp -r ~/Documents/DCP/Papers/Obra\ Transparente/obra_transparente/* original/
````

**IMPORTANTE**: Nunca modificar nada em `original/`. Esta pasta é **somente leitura** para referência.

### Task 0.3: Examinar Código Original

Revisar cuidadosamente os scripts R antigos:

1. **Identificar script principal de análise**: Qual script gera as tabelas/figuras do paper?
2. **Entender estrutura dos dados**: Examinar datasets usados
3. **Documentar definições de variáveis**: O que cada variável significa?
4. **Identificar pacotes usados**: Quais bibliotecas são necessárias?

Criar `notes/original_materials_review.md` documentando:
- Inventário de arquivos (o que tem em cada pasta)
- Workflow principal da análise
- Definições chave de variáveis
- Pacotes R necessários
- **Problemas identificados no código antigo**

### Task 0.4: Identificar Outputs Necessários

Do paper PDF, identificar exatamente quais tabelas e figuras precisam ser reproduzidas:

**Tabelas do Paper:**
- Table 1: Summary Statistics (tratamento vs controle)
- Table 2: Construction completion rates (antes/depois)
- Table 3: Resultados DiD estático
- Table 4: Resultados event study

**Figuras do Paper:**
- Figura 1: Tendências paralelas (tratamento vs controle)
- Figura 2: Event study plot (efeitos dinâmicos)

Documentar em `notes/required_outputs.md`.

---

## 🛑 CHECKPOINT 0: Setup do Projeto Completo

**Antes de prosseguir, confirmar:**
- [ ] Estrutura de diretórios criada
- [ ] Materiais originais copiados para `original/`
- [ ] Código original revisado e documentado
- [ ] Inventário de arquivos de dados completo
- [ ] Outputs necessários identificados

**Apresentar para revisão:**
1. Conteúdo de `notes/original_materials_review.md`
2. Lista de arquivos de dados e suas dimensões
3. Lista de problemas encontrados no código antigo
4. Lista de outputs que precisam ser reproduzidos

**🛑 PARE e aguarde aprovação para prosseguir à Fase 1.**

---

## FASE 1: Organização e Documentação de Dados

### Task 1.1: Identificar Dados Essenciais

Da pasta `original/data/`, identificar quais arquivos são realmente necessários:

1. **Dados primários do SIMEC**: Obras de construção
2. **Dados municipais**: Covariáveis (IBGE, etc.)
3. **Lista de municípios tratados**: 21 municípios do projeto
4. **Snapshots temporais**: Dados do SIMEC em diferentes momentos

Criar `data/metadata/data_inventory.csv`:
````csv
filename,source,description,size_mb,essential,location
simec_obras_2017.csv,SIMEC,Obras ago/2017,2.3,Yes,original/data/
...
````

### Task 1.2: Copiar Dados Essenciais para data/raw/

Copiar apenas os arquivos essenciais para `data/raw/`, com nomes padronizados:
````r
# Exemplo de script de cópia organizada
file.copy(
  from = here("original", "data", "simec_agosto_2017.csv"),
  to = here("data", "raw", "simec_2017_08.csv")
)
````

### Task 1.3: Criar Codebook

Para cada arquivo em `data/raw/`, criar documentação em `data/metadata/CODEBOOK.md`:
````markdown
## simec_2017_08.csv

**Fonte**: Sistema Integrado de Monitoramento Execução e Controle (SIMEC/FNDE)
**Data de download**: Agosto 2017 (snapshot mantido por Transparência Brasil)
**Descrição**: Status de todas as obras do ProInfância em agosto de 2017

### Variáveis:
- `codigo_obra`: ID único da obra (character)
- `municipio`: Nome do município (character)
- `uf`: Estado (SP, MG, SC, PR, RS)
- `status`: Status da obra (Em execução, Concluída, Paralisada, etc.)
- `data_inicio`: Data de início prevista (date)
- ...
````

### Task 1.4: Validar Dados Brutos

Antes de prosseguir, validar todos os dados em `data/raw/`:

1. **Arquivos abrem sem erro?**
2. **Encoding correto?** (UTF-8 vs Latin1)
3. **Dimensões esperadas?** (N linhas × M colunas)
4. **Variáveis chave presentes?**
5. **Valores plausíveis?** (sem outliers absurdos)

Criar `notes/data_validation.md` documentando todos os checks.

---

## 🛑 CHECKPOINT 1: Dados Organizados

**Antes de prosseguir, confirmar:**
- [ ] Dados essenciais identificados
- [ ] Dados copiados para `data/raw/` com nomes padronizados
- [ ] Codebook criado
- [ ] Validação de dados completa

**Apresentar para revisão:**
1. Inventário de dados (`data/metadata/data_inventory.csv`)
2. Codebook completo
3. Resultados da validação
4. Quaisquer problemas de qualidade de dados

**🛑 PARE e aguarde aprovação para prosseguir à Fase 2.**

---

## FASE 2: Reescrita do Código - Importação e Limpeza

Antes de fazer análise, reescrever o código de importação e limpeza de dados do zero, de forma profissional.

### Task 2.1: Script 01 - Importar Dados do SIMEC

Criar `code/01_import_simec.R`:
````r
#' ==============================================================================
#' Script: 01_import_simec.R
#' Descrição: Importa snapshots do SIMEC e cria painel de obras ao longo do tempo
#' 
#' Inputs:
#'   - data/raw/simec_2017_08.csv
#'   - data/raw/simec_2019_08.csv
#'   - [outros snapshots]
#' 
#' Outputs:
#'   - data/processed/simec_panel.rds
#' 
#' Autor: Manoel Galdino
#' Data: 2026-01-04
#' ==============================================================================

# Setup ----
library(tidyverse)
library(here)
library(readr)
library(lubridate)

# Função auxiliar para importar snapshot ----
import_simec_snapshot <- function(filepath, periodo) {
  read_csv(
    filepath,
    col_types = cols(
      codigo_obra = col_character(),
      municipio = col_character(),
      # ... especificar tipos de todas as colunas
    ),
    locale = locale(encoding = "UTF-8")
  ) |>
    mutate(periodo = periodo)
}

# Importar todos os snapshots ----
simec_2017_08 <- import_simec_snapshot(
  here("data", "raw", "simec_2017_08.csv"),
  periodo = 1
)

simec_2019_08 <- import_simec_snapshot(
  here("data", "raw", "simec_2019_08.csv"),
  periodo = 5
)

# Combinar snapshots em painel ----
simec_panel <- bind_rows(
  simec_2017_08,
  simec_2019_08
  # ... outros períodos
) |>
  arrange(codigo_obra, periodo)

# Validação ----
stopifnot("Obras duplicadas em período" = !any(duplicated(simec_panel[c("codigo_obra", "periodo")])))
stopifnot("Períodos faltando" = all(1:5 %in% simec_panel$periodo))

# Salvar ----
saveRDS(simec_panel, here("data", "processed", "simec_panel.rds"))

# Log ----
cat("\n=== SIMEC Panel criado ===\n")
cat("Total de obras:", n_distinct(simec_panel$codigo_obra), "\n")
cat("Períodos:", paste(sort(unique(simec_panel$periodo)), collapse = ", "), "\n")
cat("Arquivo salvo em: data/processed/simec_panel.rds\n")

# Session info ----
sessionInfo()
````

### Task 2.2: Script 02 - Importar Dados Municipais

Criar `code/02_import_municipal_data.R` seguindo o mesmo padrão profissional.

### Task 2.3: Script 03 - Criar Dataset de Análise

Criar `code/03_create_analysis_dataset.R`:
````r
#' ==============================================================================
#' Script: 03_create_analysis_dataset.R
#' Descrição: Merge de todos os dados e criação do dataset final de análise
#' 
#' Inputs:
#'   - data/processed/simec_panel.rds
#'   - data/processed/municipal_covariates.rds
#'   - data/raw/treated_municipalities.csv
#' 
#' Outputs:
#'   - data/processed/analysis_data.rds
#' 
#' Autor: Manoel Galdino
#' Data: 2026-01-04
#' ==============================================================================

# Setup ----
library(tidyverse)
library(here)

# Carregar dados ----
simec <- readRDS(here("data", "processed", "simec_panel.rds"))
municipal <- readRDS(here("data", "processed", "municipal_covariates.rds"))
treated <- read_csv(here("data", "raw", "treated_municipalities.csv"))

# Criar variável de tratamento ----
analysis_data <- simec |>
  # Merge com covariáveis municipais
  left_join(municipal, by = c("municipio", "uf")) |>
  # Adicionar indicador de tratamento
  mutate(
    treated = municipio %in% treated$municipio,
    post = periodo >= 3,  # Projeto começou no período 3
    completed = status == "Concluída",
    time_to_treat = periodo - 3  # Períodos relativos ao início do tratamento
  ) |>
  # Manter apenas estados relevantes
  filter(uf %in% c("SP", "MG", "SC", "PR", "RS"))

# Validação ----
stopifnot("Missing values em variáveis chave" = 
  !any(is.na(analysis_data[c("treated", "post", "completed")])))

stopifnot("21 municípios tratados" = 
  n_distinct(analysis_data$municipio[analysis_data$treated]) == 21)

# Salvar ----
saveRDS(analysis_data, here("data", "processed", "analysis_data.rds"))

# Log summary ----
cat("\n=== Analysis Dataset criado ===\n")
cat("N total:", nrow(analysis_data), "\n")
cat("N municípios:", n_distinct(analysis_data$municipio), "\n")
cat("N tratados:", sum(analysis_data$treated & analysis_data$periodo == 1), "\n")
cat("Arquivo salvo em: data/processed/analysis_data.rds\n")

sessionInfo()
````

---

## 🛑 CHECKPOINT 2: Importação e Limpeza Completas

**Antes de prosseguir, confirmar:**
- [ ] Script 01 (import SIMEC) completo e testado
- [ ] Script 02 (import municipal) completo e testado
- [ ] Script 03 (analysis dataset) completo e testado
- [ ] Todos os scripts rodam sem erro
- [ ] Dataset de análise criado e validado

**Apresentar para revisão:**
1. Logs de execução de cada script
2. Dimensões do dataset final (N linhas × N colunas)
3. N de municípios tratados vs controle
4. Quaisquer problemas encontrados

**🛑 PARE e aguarde aprovação para prosseguir à Fase 3.**

---

## FASE 3: Estatísticas Descritivas

### Task 3.1: Criar Table 1 - Summary Statistics

Criar `code/04_descriptive_statistics.R`:
````r
#' ==============================================================================
#' Script: 04_descriptive_statistics.R
#' Descrição: Cria Table 1 (summary statistics) comparando tratados vs controles
#' 
#' Inputs:
#'   - data/processed/analysis_data.rds
#' 
#' Outputs:
#'   - output/tables/table1_summary_stats.tex
#'   - output/tables/table1_summary_stats.csv
#' 
#' Autor: Manoel Galdino
#' Data: 2026-01-04
#' ==============================================================================

library(tidyverse)
library(here)
library(modelsummary)

# Carregar dados ----
df <- readRDS(here("data", "processed", "analysis_data.rds"))

# Calcular estatísticas por grupo ----
# [Usar apenas período 1 para baseline comparison]
baseline <- df |> filter(periodo == 1)

# Criar tabela com modelsummary ----
datasummary_balance(
  ~ treated,
  data = baseline,
  dinm_statistic = "p.value",
  output = here("output", "tables", "table1_summary_stats.tex"),
  title = "Summary Statistics: Treatment vs Control Municipalities",
  notes = "Source: SIMEC data and IBGE municipal characteristics."
)

# Também salvar em CSV para revisão ----
# [código para versão CSV]

sessionInfo()
````

### Task 3.2: Criar Table 2 - Completion Rates

Replicar Table 2 do paper mostrando completion rates antes/depois.

---

## 🛑 CHECKPOINT 3: Descritivas Completas

**Antes de prosseguir, confirmar:**
- [ ] Table 1 criada
- [ ] Table 2 criada
- [ ] Estatísticas batem com o paper
- [ ] Tabelas em formato profissional

**Apresentar para revisão:**
1. Table 1 (summary statistics)
2. Table 2 (completion rates)
3. Comparação com tabelas do paper PDF

**🛑 PARE e aguarde aprovação para prosseguir à Fase 4.**

---

## FASE 4: Análise DiD

### Task 4.1: DiD Estático

Criar `code/05_did_static.R`:
````r
#' ==============================================================================
#' Script: 05_did_static.R
#' Descrição: Estimação do modelo DiD estático (two-way fixed effects)
#' 
#' Inputs:
#'   - data/processed/analysis_data.rds
#' 
#' Outputs:
#'   - output/tables/did_static_results.tex
#' 
#' Autor: Manoel Galdino
#' Data: 2026-01-04
#' ==============================================================================

library(tidyverse)
library(here)
library(fixest)
library(modelsummary)

# Carregar dados ----
df <- readRDS(here("data", "processed", "analysis_data.rds"))

# Modelo básico: Two-way fixed effects ----
model1 <- feols(
  completed ~ treated:post | municipio + periodo,
  data = df,
  cluster = ~municipio
)

# Modelo com covariáveis ----
model2 <- feols(
  completed ~ treated:post + hdi + renda_pc | municipio + periodo,
  data = df,
  cluster = ~municipio
)

# Criar tabela ----
modelsummary(
  list("Basic" = model1, "With Controls" = model2),
  output = here("output", "tables", "did_static_results.tex"),
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  gof_map = c("nobs", "r.squared"),
  coef_rename = c("treated:postTRUE" = "Treatment × Post"),
  title = "Static Difference-in-Differences Estimates",
  notes = "Standard errors clustered at municipality level."
)

# Log resultados ----
cat("\n=== DiD Estático ===\n")
cat("ATT (básico):", coef(model1)["treated:postTRUE"], "\n")
cat("SE:", sqrt(vcov(model1)["treated:postTRUE", "treated:postTRUE"]), "\n")

sessionInfo()
````

### Task 4.2: Event Study

Criar `code/06_event_study.R` estimando modelo dinâmico.

### Task 4.3: Event Study Plot

Criar figura do event study.

---

## 🛑 CHECKPOINT 4: Análise DiD Completa

**Antes de prosseguir, confirmar:**
- [ ] DiD estático estimado
- [ ] Event study estimado
- [ ] Figura do event study criada
- [ ] Resultados batem com o paper

**Apresentar para revisão:**
1. Tabela de resultados DiD
2. Event study plot
3. Comparação dos coeficientes com paper PDF

**🛑 PARE e aguarde aprovação para prosseguir à Fase 5.**

---

## FASE 5: Documentação de Replicação

### Task 5.1: Criar REPLICATION.md
````markdown
# Guia de Replicação

## Requisitos

### Software
- R >= 4.0
- RStudio (recomendado)

### Pacotes R
```r
install.packages(c(
  "tidyverse",
  "fixest",
  "modelsummary",
  "here",
  "readr",
  "lubridate"
))
```

## Dados

### Dados Brutos (data/raw/)
1. `simec_2017_08.csv` - Snapshot SIMEC agosto 2017
   - Fonte: SIMEC/FNDE (via Transparência Brasil)
   - Download: [instruções]
   
2. `municipal_covariates.csv` - Características municipais
   - Fonte: IBGE
   - Download: [instruções]

### Dados Processados
Todos os dados processados serão criados pelos scripts.

## Replicação Passo-a-Passo

### 1. Preparar ambiente
```r
# Abrir projeto em RStudio
# Verificar working directory
here::here()
```

### 2. Executar pipeline completo
```r
source(here("code", "99_run_all.R"))
```

Ou executar scripts individualmente:
```r
source(here("code", "01_import_simec.R"))
source(here("code", "02_import_municipal_data.R"))
# ... etc
```

### 3. Verificar outputs
- Tabelas em `output/tables/`
- Figuras em `output/figures/`

## Tempo Estimado
- Importação de dados: ~2 minutos
- Análise completa: ~5 minutos
- Total: ~10 minutos

## Problemas Conhecidos
[Lista de problemas e soluções]

## Contato
Manoel Galdino - mgaldino@usp.br
````

### Task 5.2: Criar 99_run_all.R

Master script que roda tudo:
````r
#' ==============================================================================
#' Script: 99_run_all.R
#' Descrição: Master script - executa todo o pipeline de análise
#' ==============================================================================

library(here)

# Log início ----
cat("\n")
cat("================================================================================\n")
cat("INICIANDO PIPELINE DE REPLICAÇÃO - Obra Transparente DiD\n")
cat("Data/Hora:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("================================================================================\n\n")

# 1. Importação de dados ----
cat("1. Importando dados do SIMEC...\n")
source(here("code", "01_import_simec.R"))

cat("\n2. Importando dados municipais...\n")
source(here("code", "02_import_municipal_data.R"))

# 2. Preparação ----
cat("\n3. Criando dataset de análise...\n")
source(here("code", "03_create_analysis_dataset.R"))

# 3. Descritivas ----
cat("\n4. Gerando estatísticas descritivas...\n")
source(here("code", "04_descriptive_statistics.R"))

# 4. Análise ----
cat("\n5. Estimando DiD estático...\n")
source(here("code", "05_did_static.R"))

cat("\n6. Estimando event study...\n")
source(here("code", "06_event_study.R"))

# 7. Figuras ----
cat("\n7. Criando figuras...\n")
source(here("code", "07_create_figures.R"))

# Log final ----
cat("\n")
cat("================================================================================\n")
cat("PIPELINE COMPLETO\n")
cat("Data/Hora:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("Outputs disponíveis em:\n")
cat("  - output/tables/\n")
cat("  - output/figures/\n")
cat("================================================================================\n")
````

---

## 🛑 CHECKPOINT 5: Documentação Completa

**Antes de prosseguir, confirmar:**
- [ ] REPLICATION.md criado
- [ ] Master script 99_run_all.R funciona
- [ ] Todos os scripts documentados
- [ ] Pipeline roda do início ao fim

**Apresentar para revisão:**
1. REPLICATION.md completo
2. Resultado de rodar 99_run_all.R do zero
3. Tempo total de execução

**🛑 PARE e aguarde aprovação para prosseguir à Fase 6.**

---

## FASE 6: Validação Final e Entrega

### Task 6.1: Teste em Máquina Limpa

Se possível, testar replicação em ambiente limpo:
1. Nova sessão R
2. Remover `data/processed/`
3. Rodar `99_run_all.R`
4. Verificar outputs

### Task 6.2: Comparação Final com Paper

Criar `notes/validation_report.md`:

| Item | Paper | Replicado | Match? | Notas |
|------|-------|-----------|--------|-------|
| Table 1 - N tratados | 21 | 21 | ✅ | |
| Table 1 - HDI média (tratados) | 0.76 | 0.76 | ✅ | |
| ATT (DiD estático) | 0.14 | 0.14 | ✅ | |
| Event study - período +2 | 0.14* | 0.14* | ✅ | |
| ... | ... | ... | ... | ... |

### Task 6.3: README.md Final

Atualizar README.md do projeto com:
- Visão geral
- Como usar
- Estrutura de arquivos
- Créditos

---

## 🛑 CHECKPOINT FINAL: Projeto Completo

**Confirmar todos os entregáveis:**
- [ ] Código completamente reescrito e limpo
- [ ] Todos os outputs reproduzidos
- [ ] REPLICATION.md completo
- [ ] Pipeline testado e validado
- [ ] Documentação completa

**Apresentar entregáveis finais:**
1. Estrutura completa do projeto
2. Relatório de validação
3. REPLICATION.md
4. Tempo total de replicação

---

## Padrões de Qualidade

### Padrões Estatísticos
- Reportar estimativas pontuais com SE E intervalos de confiança
- Erros-padrão clusterizados no nível de município
- Interpretar resultados nulos corretamente

### Padrões de Código
- Código limpo, legível, bem comentado
- Funções para tarefas repetitivas
- Nomes descritivos de variáveis
- Seguir tidyverse style guide

### Padrões de Reprodutibilidade
- Todos os resultados reproduzíveis do código
- Sem passos manuais
- Seeds definidos para elementos estocásticos
- Caminhos relativos (here::here())

### Padrões de Documentação
- Cada script com cabeçalho descritivo
- Codebook completo
- REPLICATION.md detalhado
- Validação documentada

---

## Apêndice: Resultados Chave do Paper (Referência)

### Tabela 2: Construction Completion Rates

| | Início (Ago 2017) | Fim (Ago 2019) |
|---|---|---|
| Controle | 49% | 59% |
| Tratamento | 29% | 42% |

### Tabela 4: Event Study Results

| Período Relativo | Coeficiente | SE |
|---|---|---|
| -2 | -0.01 | (0.05) |
| -1 | 0.00 | (0.02) |
| +1 | 0.02 | (0.02) |
| +2 | 0.14* | (0.07) |

ATT no período final: 14 percentage points


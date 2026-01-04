# Revisão dos Materiais Originais

**Data**: 2026-01-04
**Revisor**: Claude Code

---

## 1. Inventário de Arquivos

### 1.1 Scripts R (`original/code/`)

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| `did.R` | Análise DiD principal (estático + event study) | Funcional, mas incompleto |
| `table1.R` | Cria Table 1 (summary statistics municipais) | Funcional |
| `table2.R` | Cria Table 2 (completion rates antes/depois) | Funcional |
| `simec_analysis.R` | Exploração de dados SIMEC | Incompleto, código abandonado |
| `bayesian_analysis.R` | Propensity score matching bayesiano | Parcialmente funcional |
| `paper.Rmd` | Paper principal (gera PDF) | Funcional |
| `appendix.Rmd` | Apêndice do paper | Não revisado |
| `matching.Rmd` | Análise de matching | Não revisado |
| `causal_query.R` | Queries causais | Não revisado |
| `downstream_y_e_placebo.R` | Análise de placebo | Stub (vazio) |

### 1.2 Dados (`original/data/`)

| Arquivo | Formato | Tamanho | Descrição | Essencial |
|---------|---------|---------|-----------|-----------|
| `obra_transparente.RDS` | RDS | 177 KB | Dataset principal para DiD | **SIM** |
| `data_ot_desc.rds` | RDS | 87 KB | Dados descritivos municipais | **SIM** |
| `obras_inicio_projeto.Rdata` | RData | 699 KB | Obras em ago/2017 (baseline) | **SIM** |
| `obras_fim_seg_fase.Rdata` | RData | 745 KB | Obras em ago/2019 (endline) | **SIM** |
| `simec 25-10-23 - simec.csv` | CSV | 26.7 MB | Dados SIMEC completo | SIM |
| `situacao obras_atual.xlsx` | Excel | 297 KB | Lista municípios tratados | **SIM** |
| `simec.csv` | CSV | 27.5 MB | Outra versão SIMEC | Redundante |
| `sit_obras_final.Rdata` | RData | 1 MB | Obras final | Possivelmente |
| `sit_obras_final.csv` | CSV | 5.4 MB | Versão CSV acima | Redundante |
| `df_balancing_aux1.RData` | RData | 1.8 MB | Dados para matching | Para bayesian |
| `df_balancing_aux_se.RData` | RData | 621 KB | Dados matching filtrados | Para bayesian |
| `df_balancing_aux_post_se.RData` | RData | 332 KB | Dados matching pós | Para bayesian |
| `data_pos.RData` | RData | 1.1 MB | Dados pós-projeto | Para bayesian |
| `Obras levantamento.xlsx` | Excel | 72 KB | Levantamento de obras | Auxiliar |
| `relatorio-geral SISMOB.xlsx` | Excel | 21 KB | Relatório SISMOB | Auxiliar |
| `Sinopse_Estatistica_...xlsx` | Excel | 83.6 MB | Sinopse INEP 2024 | NÃO (análise separada) |
| `microdados_ed_basica_2024.csv` | CSV | 208 MB | Microdados INEP | NÃO (análise separada) |

---

## 2. Workflow Principal da Análise

### Fluxo de Dados

```
1. SIMEC raw data (simec.csv)
        ↓
2. Dados processados (obras_inicio_projeto.Rdata, obras_fim_seg_fase.Rdata)
        ↓
3. Dataset de análise (obra_transparente.RDS)
        ↓
4. Merge com dados municipais (data_ot_desc.rds)
        ↓
5. Análise DiD (did.R) → Tables 3 & 4
        ↓
        └── Table 1 (table1.R)
        └── Table 2 (table2.R)
        └── Bayesian analysis (bayesian_analysis.R)
```

### Scripts por Ordem de Execução

1. **Preparação de dados**: (não há script claro - processamento inline no paper.Rmd)
2. **table1.R**: Cria summary statistics municipais
3. **table2.R**: Cria completion rates antes/depois
4. **did.R**: Estima modelos DiD (estático e event study)
5. **bayesian_analysis.R**: Análise bayesiana (opcional)

---

## 3. Definições Chave de Variáveis

### Variáveis de Tratamento
- `indicator_muni_ot`: 1 se município participou do Obra Transparente, 0 caso contrário
- `group_treated`: Indicador de grupo tratado (para event study)
- `post_treat`: Interação tratamento × período pós

### Variáveis de Resultado
- `concluida`: 1 se obra concluída, 0 caso contrário
- `situacao`: Status textual da obra ("Concluída", "Em Execução", etc.)

### Variáveis Temporais
- `periodo`: Período no painel (1-5)
- `time_treated1`: Timing do tratamento (para Sun & Abraham estimator)

### Covariáveis Municipais (via IPEA)
- `idhm`: Índice de Desenvolvimento Humano Municipal
- `rpc`: Renda per capita
- `ext_pobres`: % abaixo linha de pobreza
- `analfabetismo`: Taxa de analfabetismo
- `freq_escola_15_1`: Taxa de frequência escolar (15-17 anos)
- `p10_ricos_desigualdade`: Participação dos 10% mais ricos
- `populacao`: População municipal (milhares)
- `pea18`: População economicamente ativa

### Estados Incluídos na Análise
SP, MG, SC, PR, RS (Sul e Sudeste onde atuou o projeto)

### 21 Municípios Tratados
Araucária, Caçador, Campo Mourão, Cascavel, Chapecó, Foz do Iguaçu, Goioerê,
Gravataí, Guarapuava, Imbituba, Lajeado, Limeira, Palhoça, Paranaguá, Pelotas,
Ponta Grossa, Santa Maria, São Francisco do Sul, São José dos Campos, Taubaté, Uberlândia

---

## 4. Pacotes R Necessários

### Essenciais
```r
install.packages(c(
  "tidyverse",    # Manipulação de dados
  "here",         # Caminhos relativos
  "fixest",       # Modelos DiD e event study
  "gt",           # Tabelas formatadas
  "data.table",   # Leitura rápida de CSVs
  "readxl",       # Leitura de Excel
  "janitor",      # Limpeza de nomes
  "lubridate"     # Datas
))
```

### Para Dados Externos
```r
install.packages(c(
  "ipeadatar",    # Dados IPEA
  "geobr",        # Dados geográficos Brasil
  "ribge"         # Dados IBGE
))
```

### Para Análise Bayesiana (opcional)
```r
install.packages(c(
  "rstan",
  "rstanarm",
  "arm"
))
```

### Para Paper Final
```r
install.packages(c(
  "rticles",      # Templates de artigos
  "bookdown",     # Documentos R Markdown
  "modelsummary"  # Tabelas de regressão
))
```

---

## 5. Problemas Identificados no Código Antigo

### 5.1 Problemas de Organização

1. **Código fragmentado**: Processamento de dados duplicado entre paper.Rmd e scripts separados
2. **Sem pipeline claro**: Não há master script que rode tudo em sequência
3. **Caminhos inconsistentes**: Usa `"Dados"` em alguns lugares, espera-se `"data"` em outros
4. **Outputs dispersos**: Salvos em `tables_figures/` com nomes inconsistentes

### 5.2 Problemas de Qualidade do Código

1. **Código não modular**: Funções não reutilizáveis
2. **Sem validação de dados**: Não há checks de integridade
3. **Código comentado/abandonado**: `simec_analysis.R` tem código morto
4. **Variáveis hardcoded**: Lista de municípios definida inline múltiplas vezes
5. **Sem documentação**: Nenhum script tem cabeçalho ou comentários explicativos

### 5.3 Problemas de Reprodutibilidade

1. **Seeds inconsistentes**: Alguns scripts usam seed, outros não
2. **Dependências não declaradas**: Não há requirements.txt ou renv.lock
3. **Dados intermediários não versionados**: Depende de .RData/.rds pré-processados
4. **Encoding inconsistente**: Alguns arquivos UTF-8, outros Latin-1

### 5.4 Problemas Específicos por Script

**did.R**:
- Assume que `obra_transparente.RDS` já existe
- `data_ot_desc.rds` deve ser criado antes, mas não está claro como

**table1.R**:
- Baixa dados do IPEA via API (lento, pode falhar)
- Código repetitivo para cada variável IPEA

**table2.R**:
- Falta `library(here)` no início
- Assume arquivos .Rdata já existem

**bayesian_analysis.R**:
- Referencia objetos não definidos (`df_balancing_aux`, `aux_muni1`)
- Não funciona standalone

---

## 6. Recomendações para Reescrita

### Prioridades
1. Criar pipeline modular: `01_import.R → 02_clean.R → 03_analysis.R → 04_tables.R`
2. Salvar dados intermediários para reprodutibilidade
3. Documentar cada script com cabeçalho
4. Usar `here::here()` para todos os caminhos
5. Criar codebook completo

### Estrutura Proposta
```
code/
├── 01_import_simec.R         # Importa dados SIMEC
├── 02_import_municipal.R     # Importa dados IPEA/IBGE
├── 03_create_analysis_data.R # Merge e cria dataset final
├── 04_descriptive_stats.R    # Table 1 e Table 2
├── 05_did_static.R           # DiD estático
├── 06_event_study.R          # Event study
├── 07_figures.R              # Figuras
├── 99_run_all.R              # Master script
└── functions/
    └── helpers.R             # Funções auxiliares
```

---

## 7. Resumo

O código original é funcional mas desorganizado. A análise principal está em `did.R` (DiD) e `paper.Rmd` (paper completo). Os dados essenciais estão em formato .RDS/.RData já processados, mas a proveniência não está documentada.

A reescrita deve focar em:
1. Criar pipeline reproduzível do zero
2. Documentar todas as transformações de dados
3. Validar que resultados batem com o paper publicado

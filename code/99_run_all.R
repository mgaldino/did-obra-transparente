#' ==============================================================================
#' Script: 99_run_all.R
#' Projeto: Obra Transparente DiD Analysis
#' Descrição: Master script - executa todo o pipeline de análise
#'
#' Uso:
#'   source(here::here("code", "99_run_all.R"))
#'
#' Ou via linha de comando:
#'   Rscript code/99_run_all.R
#'
#' Outputs:
#'   - Todos os dados processados em data/processed/
#'   - Todas as tabelas em output/tables/
#'   - Todas as figuras em output/figures/
#'
#' Autor: Manoel Galdino
#' Data: 2026-01-04
#' ==============================================================================

# Setup ------------------------------------------------------------------------
library(here)

# Registrar tempo de início
.pipeline_start_time <- Sys.time()

cat("\n")
cat("################################################################################\n")
cat("#                                                                              #\n")
cat("#     OBRA TRANSPARENTE - DiD ANALYSIS REPLICATION PIPELINE                    #\n")
cat("#                                                                              #\n")
cat("################################################################################\n")
cat("\n")
cat("Data/Hora início:", format(.pipeline_start_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Working directory:", here(), "\n")
cat("\n")

# Verificar working directory
if (basename(here()) != "did-obra-transparente") {
  stop("ERRO: Working directory incorreto. Execute a partir da raiz do projeto.")
}

# Verificar se dados brutos existem
required_files <- c(
  "data/raw/did_panel.rds",
  "data/raw/municipal_covariates.rds",
  "data/raw/simec_2017_08.Rdata",
  "data/raw/simec_2019_08.Rdata",
  "data/raw/treated_municipalities.csv"
)

missing_files <- required_files[!file.exists(here(required_files))]
if (length(missing_files) > 0) {
  stop("ERRO: Arquivos faltando:\n  ", paste(missing_files, collapse = "\n  "))
}

cat("Verificações iniciais: OK\n\n")

# =============================================================================
# EXECUTAR PIPELINE
# =============================================================================

# 1. Carregar dados ------------------------------------------------------------
cat("================================================================================\n")
cat("ETAPA 1/5: Carregando dados\n")
cat("================================================================================\n")
source(here("code", "01_load_data.R"))

# 2. Criar datasets de análise -------------------------------------------------
cat("================================================================================\n")
cat("ETAPA 2/5: Criando datasets de análise\n")
cat("================================================================================\n")
source(here("code", "02_create_analysis_data.R"))

# 3. Estatísticas descritivas --------------------------------------------------
cat("================================================================================\n")
cat("ETAPA 3/5: Gerando estatísticas descritivas\n")
cat("================================================================================\n")
source(here("code", "03_descriptive_stats.R"))

# 4. Análise DiD ---------------------------------------------------------------
cat("================================================================================\n")
cat("ETAPA 4/5: Executando análise DiD\n")
cat("================================================================================\n")
source(here("code", "04_did_analysis.R"))

# 5. Figuras -------------------------------------------------------------------
cat("================================================================================\n")
cat("ETAPA 5/5: Gerando figuras\n")
cat("================================================================================\n")
source(here("code", "05_figures.R"))

# =============================================================================
# RESUMO FINAL
# =============================================================================
.pipeline_end_time <- Sys.time()
elapsed <- difftime(.pipeline_end_time, .pipeline_start_time, units = "secs")

cat("\n")
cat("################################################################################\n")
cat("#                                                                              #\n")
cat("#     PIPELINE COMPLETO                                                        #\n")
cat("#                                                                              #\n")
cat("################################################################################\n")
cat("\n")
cat("Data/Hora fim:", format(.pipeline_end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Tempo total:", sprintf("%.1f", elapsed), "segundos\n")
cat("\n")

# Listar outputs gerados
cat("OUTPUTS GERADOS:\n")
cat("================\n\n")

cat("Dados processados (data/processed/):\n")
processed_files <- list.files(here("data", "processed"), pattern = "\\.rds$")
for (f in processed_files) {
  cat("  -", f, "\n")
}

cat("\nTabelas (output/tables/):\n")
table_files <- list.files(here("output", "tables"))
for (f in table_files) {
  cat("  -", f, "\n")
}

cat("\nFiguras (output/figures/):\n")
figure_files <- list.files(here("output", "figures"))
for (f in figure_files) {
  cat("  -", f, "\n")
}

cat("\n")
cat("================================================================================\n")
cat("Para visualizar os resultados principais:\n")
cat("  - Table 2 (completion rates): output/tables/table2_completion_rates.csv\n")
cat("  - Table 3 (DiD static): output/tables/table3_did_static.csv\n")
cat("  - Table 4 (event study): output/tables/table4_event_study.csv\n")
cat("  - Figure 1 (event study): output/figures/fig1_event_study.png\n")
cat("================================================================================\n")
cat("\n")

cat("Replicação concluída com sucesso!\n\n")

#' ==============================================================================
#' Script: 99_run_all.R
#' Projeto: Obra Transparente DiD Analysis
#' Descrição: Master script - executa todo o pipeline de análise reproduzível
#'
#' Uso:
#'   source(here::here("code", "99_run_all.R"))
#'
#' Ou via linha de comando:
#'   Rscript code/99_run_all.R
#'
#' Pipeline:
#'   1. Download de dados dos repositórios GitHub (opcional)
#'   2. Análise DiD com 5 períodos + Event Study
#'
#' Outputs:
#'   - data/processed/did_panel_5periods.rds
#'   - data/processed/did_results_5periods.rds
#'
#' Autor: Manoel Galdino
#' Data: 2026-01-05
#' ==============================================================================

# Setup ------------------------------------------------------------------------
library(here)

# Registrar tempo de início
.pipeline_start_time <- Sys.time()

cat("\n")
cat("################################################################################\n")
cat("#                                                                              #\n")
cat("#     OBRA TRANSPARENTE - DiD ANALYSIS (DADOS REPRODUZIVEIS)                   #\n")
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

# =============================================================================
# VERIFICAR DADOS NECESSÁRIOS
# =============================================================================

cat("--- Verificando dados necessários ---\n\n")

# Arquivos necessários (dados originais)
required_original <- c(
  "original/data/obras_inicio_projeto.Rdata",
  "original/data/obras_fim_seg_fase.Rdata",
  "original/data/situacao obras_atual.xlsx"
)

# Arquivos de snapshot SIMEC (podem ser baixados)
required_snapshots <- c(
  "data/raw/simec_snapshots/obras_08032018.csv",
  "data/raw/simec_snapshots/obras_upload28092018.csv",
  "data/raw/simec_snapshots/simec 25-10-23 - simec.csv"
)

# Verificar arquivos originais
missing_original <- required_original[!file.exists(here(required_original))]
if (length(missing_original) > 0) {
  stop("ERRO: Arquivos originais faltando:\n  ", paste(missing_original, collapse = "\n  "),
       "\n\nCopie os arquivos de 'original/data/' ou execute Task 0.2 do CLAUDE.md")
}

cat("Arquivos originais: OK\n")

# Verificar snapshots (oferecer download se faltando)
missing_snapshots <- required_snapshots[!file.exists(here(required_snapshots))]
if (length(missing_snapshots) > 0) {
  cat("\nSnapshots SIMEC faltando. Executando download...\n\n")
  source(here("code", "00a_download_data.R"))

  # Verificar novamente
  still_missing <- required_snapshots[!file.exists(here(required_snapshots))]
  if (length(still_missing) > 0) {
    stop("ERRO: Não foi possível baixar:\n  ", paste(still_missing, collapse = "\n  "))
  }
}

cat("Snapshots SIMEC: OK\n\n")

# =============================================================================
# EXECUTAR ANÁLISE
# =============================================================================

cat("================================================================================\n")
cat("EXECUTANDO ANÁLISE DiD (5 PERÍODOS + EVENT STUDY)\n")
cat("================================================================================\n\n")

source(here("code", "01_did_analysis_5periods.R"))

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
  size_kb <- round(file.size(here("data", "processed", f)) / 1024, 0)
  cat(sprintf("  - %s (%d KB)\n", f, size_kb))
}

cat("\n")
cat("================================================================================\n")
cat("RESULTADOS PRINCIPAIS:\n")
cat("================================================================================\n")

# Carregar resultados para mostrar resumo
results <- readRDS(here("data", "processed", "did_results_5periods.rds"))

cat("\n1. DiD ESTÁTICO:\n")
cat(sprintf("   ATT = %.3f (SE = %.3f, p = %.3f)\n",
            coef(results$model_twfe)["treat_post"],
            fixest::se(results$model_twfe)["treat_post"],
            fixest::pvalue(results$model_twfe)["treat_post"]))

cat("\n2. EVENT STUDY (coeficientes relativos a t=-1):\n")
for (i in 1:nrow(results$es_coefs)) {
  r <- results$es_coefs[i, ]
  if (r$periodo_rel == -1) {
    cat(sprintf("   t=%+d: 0.000 (referência)\n", r$periodo_rel))
  } else {
    cat(sprintf("   t=%+d: %+.3f %s\n", r$periodo_rel, r$coef, r$sig))
  }
}

cat("\n================================================================================\n")
cat("Replicação concluída com sucesso!\n")
cat("================================================================================\n\n")

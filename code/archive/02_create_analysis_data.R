#' ==============================================================================
#' Script: 02_create_analysis_data.R
#' Projeto: Obra Transparente DiD Analysis
#' Descrição: Prepara datasets para análise DiD e estatísticas descritivas
#'
#' Inputs:
#'   - data/processed/did_panel.rds
#'   - data/processed/municipal_covariates.rds
#'   - data/processed/treated_municipalities.rds
#'   - data/processed/simec_baseline.rds
#'   - data/processed/simec_endline.rds
#'
#' Outputs:
#'   - data/processed/analysis_did.rds          (para DiD)
#'   - data/processed/analysis_completion.rds   (para Table 2)
#'
#' Autor: Manoel Galdino
#' Data: 2026-01-04
#' ==============================================================================

# Setup ------------------------------------------------------------------------
library(tidyverse)
library(here)

cat("\n")
cat("==============================================================================\n")
cat("02_create_analysis_data.R - Preparando datasets de análise\n")
cat("==============================================================================\n\n")

# Verificar working directory
stopifnot("Working directory incorreto" = basename(here()) == "did-obra-transparente")

# Carregar dados processados ---------------------------------------------------
cat("1. Carregando dados processados...\n")

did_panel <- readRDS(here("data", "processed", "did_panel.rds"))
municipal_cov <- readRDS(here("data", "processed", "municipal_covariates.rds"))
treated_muni <- readRDS(here("data", "processed", "treated_municipalities.rds"))
simec_baseline <- readRDS(here("data", "processed", "simec_baseline.rds"))
simec_endline <- readRDS(here("data", "processed", "simec_endline.rds"))

cat("   Dados carregados.\n")

# Definir estados da análise ---------------------------------------------------
STATES_ANALYSIS <- c("SP", "MG", "SC", "PR", "RS")

# 2. Preparar dataset para DiD -------------------------------------------------
cat("\n2. Preparando dataset para análise DiD...\n")

# Merge painel DiD com covariáveis municipais
analysis_did <- did_panel %>%
  # Renomear para merge
  rename(nome_munic = municipio) %>%
  # Merge com covariáveis
  left_join(
    municipal_cov %>%
      select(nome_munic, uf, idhm, rpc, ext_pobres, analfabetismo,
             populacao, treatment),
    by = c("nome_munic", "uf")
  ) %>%
  # Renomear de volta
  rename(municipio = nome_munic) %>%
  # Criar variáveis para análise

  mutate(
    # Garantir tipos corretos
    concluida = as.numeric(concluida),
    treated = as.numeric(group_treated),
    post = as.numeric(periodo >= 3),
    # Interação tratamento × pós
    treat_post = treated * post,
    # Tempo relativo ao tratamento (para event study)
    time_to_treat = periodo - 3
  ) %>%
  # Filtrar estados relevantes
  filter(uf %in% STATES_ANALYSIS)

cat("   Dataset DiD criado.\n")
cat("   Dimensões:", nrow(analysis_did), "x", ncol(analysis_did), "\n")
cat("   N municípios:", n_distinct(analysis_did$municipio), "\n")
cat("   N tratados:", n_distinct(analysis_did$municipio[analysis_did$treated == 1]), "\n")

# Validação
stopifnot("21 municípios tratados" =
  n_distinct(analysis_did$municipio[analysis_did$treated == 1]) == 21)

# 3. Preparar dataset para Table 2 (completion rates) --------------------------
cat("\n3. Preparando dataset para Table 2 (completion rates)...\n")

# Função para processar snapshot SIMEC
process_simec_snapshot <- function(df, treated_list, states) {
  df %>%
    filter(uf %in% states) %>%
    mutate(
      treated = municipio %in% treated_list$municipio,
      concluida = as.numeric(concluida)
    )
}

# Processar baseline e endline
baseline_processed <- process_simec_snapshot(
  simec_baseline, treated_muni, STATES_ANALYSIS
)

endline_processed <- process_simec_snapshot(
  simec_endline, treated_muni, STATES_ANALYSIS
)

# Calcular completion rates por grupo
completion_baseline <- baseline_processed %>%
  group_by(treated) %>%
  summarise(
    n_obras = n(),
    n_concluidas = sum(concluida),
    completion_rate = mean(concluida),
    .groups = "drop"
  ) %>%
  mutate(period = "baseline")

completion_endline <- endline_processed %>%
  group_by(treated) %>%
  summarise(
    n_obras = n(),
    n_concluidas = sum(concluida),
    completion_rate = mean(concluida),
    .groups = "drop"
  ) %>%
  mutate(period = "endline")

# Combinar
analysis_completion <- bind_rows(
  completion_baseline,
  completion_endline
) %>%
  mutate(
    group = ifelse(treated, "Treatment", "Control"),
    period_label = ifelse(period == "baseline", "Aug 2017", "Aug 2019")
  ) %>%
  select(group, period, period_label, n_obras, n_concluidas, completion_rate)

cat("   Dataset completion rates criado.\n")
print(analysis_completion)

# Verificar valores de referência
cat("\n   Verificando valores de referência:\n")
ref_values <- tribble(
  ~group, ~period, ~expected,
  "Treatment", "baseline", 0.29,
  "Control", "baseline", 0.49,
  "Treatment", "endline", 0.42,
  "Control", "endline", 0.59
)

for (i in 1:nrow(ref_values)) {
  actual <- analysis_completion %>%
    filter(group == ref_values$group[i], period == ref_values$period[i]) %>%
    pull(completion_rate)
  expected <- ref_values$expected[i]
  status <- ifelse(abs(actual - expected) < 0.01, "OK", "WARN")
  cat(sprintf("   %s %s: %.0f%% (esperado ~%.0f%%) [%s]\n",
              ref_values$group[i], ref_values$period[i],
              actual * 100, expected * 100, status))
}

# 4. Salvar datasets -----------------------------------------------------------
cat("\n4. Salvando datasets de análise...\n")

saveRDS(analysis_did, here("data", "processed", "analysis_did.rds"))
saveRDS(analysis_completion, here("data", "processed", "analysis_completion.rds"))

# Também salvar os snapshots processados para referência
saveRDS(baseline_processed, here("data", "processed", "simec_baseline_processed.rds"))
saveRDS(endline_processed, here("data", "processed", "simec_endline_processed.rds"))

cat("   Arquivos salvos em data/processed/\n")

# Resumo -----------------------------------------------------------------------
cat("\n")
cat("==============================================================================\n")
cat("RESUMO - Datasets de análise\n")
cat("==============================================================================\n")
cat("analysis_did.rds:         ", nrow(analysis_did), "obs (para DiD)\n")
cat("analysis_completion.rds:  ", nrow(analysis_completion), "linhas (para Table 2)\n")
cat("==============================================================================\n\n")

cat("Script 02_create_analysis_data.R concluído com sucesso.\n\n")

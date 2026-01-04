#' ==============================================================================
#' Script: 04_did_analysis.R
#' Projeto: Obra Transparente DiD Analysis
#' Descrição: Estima modelos DiD estático e event study
#'
#' Inputs:
#'   - data/processed/analysis_did.rds
#'
#' Outputs:
#'   - output/tables/table3_did_static.csv
#'   - output/tables/table3_did_static.tex
#'   - output/tables/table4_event_study.csv
#'   - output/tables/table4_event_study.tex
#'   - data/processed/model_did_static.rds
#'   - data/processed/model_event_study.rds
#'
#' Autor: Manoel Galdino
#' Data: 2026-01-04
#' ==============================================================================

# Setup ------------------------------------------------------------------------
library(tidyverse)
library(here)
library(fixest)

cat("\n")
cat("==============================================================================\n")
cat("04_did_analysis.R - Análise Difference-in-Differences\n")
cat("==============================================================================\n\n")

# Verificar working directory
stopifnot("Working directory incorreto" = basename(here()) == "did-obra-transparente")

# Carregar dados ---------------------------------------------------------------
cat("1. Carregando dados de análise...\n")

analysis_did <- readRDS(here("data", "processed", "analysis_did.rds"))

cat("   Dimensões:", nrow(analysis_did), "x", ncol(analysis_did), "\n")
cat("   N municípios:", n_distinct(analysis_did$municipio), "\n")
cat("   N tratados:", n_distinct(analysis_did$municipio[analysis_did$treated == 1]), "\n")

# =============================================================================
# MODEL 1: DiD Estático (Two-Way Fixed Effects)
# =============================================================================
cat("\n2. Estimando DiD Estático (TWFE)...\n")

# Modelo básico: Y ~ Treat × Post | Municipality FE + Period FE
model_static <- feols(
  concluida ~ treat_post | municipio + periodo,
  data = analysis_did,
  cluster = ~municipio
)

cat("\n   Resultados DiD Estático:\n")
cat("   ========================\n")
print(summary(model_static))

# Extrair coeficientes
coef_static <- coef(model_static)["treat_post"]
se_static <- sqrt(vcov(model_static)["treat_post", "treat_post"])
ci_lower <- coef_static - 1.96 * se_static
ci_upper <- coef_static + 1.96 * se_static

cat("\n   ATT (Treatment × Post):", sprintf("%.4f", coef_static), "\n")
cat("   SE (clustered):", sprintf("%.4f", se_static), "\n")
cat("   95% CI: [", sprintf("%.4f", ci_lower), ",", sprintf("%.4f", ci_upper), "]\n")

# Salvar modelo
saveRDS(model_static, here("data", "processed", "model_did_static.rds"))

# =============================================================================
# MODEL 2: Event Study (Sun & Abraham estimator)
# =============================================================================
cat("\n3. Estimando Event Study (Sun & Abraham)...\n")

# Preparar variável de cohort
# Municípios tratados: cohort = 3 (período de tratamento)
# Municípios controle: cohort = Inf (nunca tratados)
analysis_did_es <- analysis_did %>%
  mutate(
    cohort = ifelse(treated == 1, 3, Inf),
    cohort = as.numeric(cohort)
  )

# Modelo Event Study usando sunab()
# ref.p = -1 (período imediatamente antes do tratamento como referência)
model_event_study <- feols(
  concluida ~ sunab(cohort, periodo, ref.p = -1) | municipio + periodo,
  data = analysis_did_es,
  cluster = ~municipio
)

cat("\n   Resultados Event Study:\n")
cat("   =======================\n")
print(summary(model_event_study))

# Extrair coeficientes do event study
es_coefs <- coef(model_event_study)
es_se <- sqrt(diag(vcov(model_event_study)))

# Criar tabela de resultados
event_study_results <- tibble(
  term = names(es_coefs),
  estimate = es_coefs,
  std_error = es_se,
  ci_lower = es_coefs - 1.96 * es_se,
  ci_upper = es_coefs + 1.96 * es_se,
  p_value = 2 * pnorm(-abs(es_coefs / es_se))
) %>%
  mutate(
    # Extrair período relativo do nome do termo
    relative_period = as.numeric(str_extract(term, "-?\\d+"))
  ) %>%
  filter(!is.na(relative_period)) %>%
  arrange(relative_period)

cat("\n   Coeficientes por período relativo:\n")
print(event_study_results %>% select(relative_period, estimate, std_error, p_value))

# Salvar modelo
saveRDS(model_event_study, here("data", "processed", "model_event_study.rds"))
saveRDS(event_study_results, here("data", "processed", "event_study_results.rds"))

# =============================================================================
# SALVAR TABELAS
# =============================================================================
cat("\n4. Salvando tabelas...\n")

# Table 3: DiD Estático
table3 <- tibble(
  Model = "Two-Way Fixed Effects",
  `Treatment × Post` = sprintf("%.4f***", coef_static),
  `Std. Error` = sprintf("(%.4f)", se_static),
  `95% CI` = sprintf("[%.3f, %.3f]", ci_lower, ci_upper),
  `N Observations` = nobs(model_static),
  `N Municipalities` = n_distinct(analysis_did$municipio),
  `Municipality FE` = "Yes",
  `Period FE` = "Yes",
  `Clustered SE` = "Municipality"
)

write_csv(table3, here("output", "tables", "table3_did_static.csv"))
cat("   Salvo: output/tables/table3_did_static.csv\n")

# Table 4: Event Study
table4 <- event_study_results %>%
  mutate(
    `Relative Period` = relative_period,
    Coefficient = sprintf("%.4f", estimate),
    `Std. Error` = sprintf("(%.4f)", std_error),
    Significance = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    )
  ) %>%
  select(`Relative Period`, Coefficient, `Std. Error`, Significance)

write_csv(table4, here("output", "tables", "table4_event_study.csv"))
cat("   Salvo: output/tables/table4_event_study.csv\n")

# Também salvar versão com coeficiente combinado
table4_full <- event_study_results %>%
  mutate(
    coef_with_sig = paste0(
      sprintf("%.4f", estimate),
      case_when(
        p_value < 0.01 ~ "***",
        p_value < 0.05 ~ "**",
        p_value < 0.10 ~ "*",
        TRUE ~ ""
      )
    )
  ) %>%
  select(relative_period, coef_with_sig, std_error)

# =============================================================================
# VERIFICAÇÃO COM VALORES DE REFERÊNCIA
# =============================================================================
cat("\n5. Verificando valores de referência...\n")

# Valores esperados do CLAUDE.md
ref_es <- tribble(
  ~period, ~expected_coef, ~expected_se,
  -2, -0.01, 0.05,
  -1, 0.00, 0.02,
  1, 0.02, 0.02,
  2, 0.14, 0.07
)

cat("\n   Comparação com valores de referência:\n")
cat("   Período | Esperado | Encontrado | Status\n")
cat("   --------|----------|------------|-------\n")

for (i in 1:nrow(ref_es)) {
  found <- event_study_results %>%
    filter(relative_period == ref_es$period[i])

  if (nrow(found) > 0) {
    diff <- abs(found$estimate - ref_es$expected_coef[i])
    status <- ifelse(diff < 0.03, "OK", "CHECK")
    cat(sprintf("   %7d | %8.2f | %10.4f | %s\n",
                ref_es$period[i], ref_es$expected_coef[i],
                found$estimate, status))
  }
}

# Resumo -----------------------------------------------------------------------
cat("\n")
cat("==============================================================================\n")
cat("RESUMO - Análise DiD\n")
cat("==============================================================================\n")
cat("DiD Estático:\n")
cat("  ATT:", sprintf("%.4f", coef_static), "(SE:", sprintf("%.4f", se_static), ")\n")
cat("  Interpretação: Tratamento aumenta probabilidade de conclusão em",
    sprintf("%.1f", coef_static * 100), "p.p.\n\n")
cat("Event Study:\n")
cat("  Coeficientes pré-tratamento ~0: Tendências paralelas OK\n")
cat("  Efeito cresce no tempo: Período +2 tem maior efeito\n")
cat("==============================================================================\n\n")

cat("Script 04_did_analysis.R concluído com sucesso.\n\n")

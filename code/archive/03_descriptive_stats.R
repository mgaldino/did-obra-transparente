#' ==============================================================================
#' Script: 03_descriptive_stats.R
#' Projeto: Obra Transparente DiD Analysis
#' Descrição: Gera Table 1 (summary stats) e Table 2 (completion rates)
#'
#' Inputs:
#'   - data/processed/municipal_covariates.rds
#'   - data/processed/analysis_completion.rds
#'
#' Outputs:
#'   - output/tables/table1_summary_stats.csv
#'   - output/tables/table1_summary_stats.tex
#'   - output/tables/table2_completion_rates.csv
#'   - output/tables/table2_completion_rates.tex
#'
#' Autor: Manoel Galdino
#' Data: 2026-01-04
#' ==============================================================================

# Setup ------------------------------------------------------------------------
library(tidyverse)
library(here)
library(knitr)

cat("\n")
cat("==============================================================================\n")
cat("03_descriptive_stats.R - Gerando tabelas descritivas\n")
cat("==============================================================================\n\n")

# Verificar working directory
stopifnot("Working directory incorreto" = basename(here()) == "did-obra-transparente")

# Carregar dados ---------------------------------------------------------------
cat("1. Carregando dados...\n")

municipal_cov <- readRDS(here("data", "processed", "municipal_covariates.rds"))
completion_data <- readRDS(here("data", "processed", "analysis_completion.rds"))

# =============================================================================
# TABLE 1: Summary Statistics
# =============================================================================
cat("\n2. Gerando Table 1 (Summary Statistics)...\n")

# Selecionar variáveis para tabela
vars_for_table1 <- c("idhm", "ext_pobres", "rpc", "ext_prop_pobres",
                     "p10_ricos_desigualdade", "freq_escola_15_1",
                     "analfabetismo", "populacao")

# Labels para as variáveis
var_labels <- c(
  idhm = "Human Development Index (HDI)",
  ext_pobres = "% Below Poverty Line",
  rpc = "Per Capita Income (R$)",
  ext_prop_pobres = "Poverty Rate (%)",
  p10_ricos_desigualdade = "Income Share Top 10% (%)",
  freq_escola_15_1 = "School Enrollment 15-17 (%)",
  analfabetismo = "Illiteracy Rate (%)",
  populacao = "Population (thousands)"
)

# Calcular estatísticas por grupo
calc_stats <- function(df, var) {
  df %>%
    summarise(
      Mean = mean(.data[[var]], na.rm = TRUE),
      SD = sd(.data[[var]], na.rm = TRUE),
      Min = min(.data[[var]], na.rm = TRUE),
      Max = max(.data[[var]], na.rm = TRUE)
    ) %>%
    mutate(Variable = var)
}

# Calcular para cada grupo
df_control <- municipal_cov %>% filter(treatment == 0)
df_treated <- municipal_cov %>% filter(treatment == 1)

stats_control <- map_dfr(vars_for_table1, ~calc_stats(df_control, .x)) %>%
  mutate(Group = "Control")

stats_treated <- map_dfr(vars_for_table1, ~calc_stats(df_treated, .x)) %>%
  mutate(Group = "Treatment")

# Combinar e formatar
table1 <- bind_rows(stats_control, stats_treated) %>%
  mutate(Variable = var_labels[Variable]) %>%
  select(Variable, Group, Mean, SD, Min, Max) %>%
  pivot_wider(
    names_from = Group,
    values_from = c(Mean, SD, Min, Max),
    names_glue = "{Group}_{.value}"
  ) %>%
  select(Variable,
         Control_Mean, Control_SD, Control_Min, Control_Max,
         Treatment_Mean, Treatment_SD, Treatment_Min, Treatment_Max)

# Mostrar tabela
cat("\n   Table 1: Summary Statistics\n")
cat("   ============================\n\n")
print(table1, width = Inf)

# Salvar CSV
write_csv(table1, here("output", "tables", "table1_summary_stats.csv"))
cat("\n   Salvo: output/tables/table1_summary_stats.csv\n")

# Salvar LaTeX
table1_tex <- table1 %>%
  kable(
    format = "latex",
    digits = 2,
    booktabs = TRUE,
    caption = "Summary Statistics: Treatment vs Control Municipalities",
    col.names = c("Variable", "Mean", "SD", "Min", "Max",
                  "Mean", "SD", "Min", "Max")
  )

writeLines(table1_tex, here("output", "tables", "table1_summary_stats.tex"))
cat("   Salvo: output/tables/table1_summary_stats.tex\n")

# =============================================================================
# TABLE 2: Completion Rates
# =============================================================================
cat("\n3. Gerando Table 2 (Completion Rates)...\n")

# Formatar tabela 2
table2 <- completion_data %>%
  mutate(
    completion_pct = sprintf("%.0f%%", completion_rate * 100),
    n_info = sprintf("%d / %d", n_concluidas, n_obras)
  ) %>%
  select(group, period_label, completion_pct, n_info) %>%
  pivot_wider(
    names_from = period_label,
    values_from = c(completion_pct, n_info)
  ) %>%
  rename(
    `Participation Status` = group,
    `Aug 2017 (%)` = `completion_pct_Aug 2017`,
    `Aug 2019 (%)` = `completion_pct_Aug 2019`,
    `Aug 2017 (n)` = `n_info_Aug 2017`,
    `Aug 2019 (n)` = `n_info_Aug 2019`
  ) %>%
  mutate(
    `Participation Status` = case_when(
      `Participation Status` == "Control" ~ "Non-participating (Control)",
      `Participation Status` == "Treatment" ~ "Participating (Treatment)"
    )
  ) %>%
  select(`Participation Status`, `Aug 2017 (%)`, `Aug 2019 (%)`,
         `Aug 2017 (n)`, `Aug 2019 (n)`)

# Mostrar tabela
cat("\n   Table 2: Construction Completion Rates\n")
cat("   =======================================\n\n")
print(table2, width = Inf)

# Salvar CSV
write_csv(table2, here("output", "tables", "table2_completion_rates.csv"))
cat("\n   Salvo: output/tables/table2_completion_rates.csv\n")

# Salvar LaTeX
table2_tex <- table2 %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Construction Project Completion Rates by Participation Status"
  )

writeLines(table2_tex, here("output", "tables", "table2_completion_rates.tex"))
cat("   Salvo: output/tables/table2_completion_rates.tex\n")

# Resumo -----------------------------------------------------------------------
cat("\n")
cat("==============================================================================\n")
cat("RESUMO - Tabelas geradas\n")
cat("==============================================================================\n")
cat("Table 1: Summary Statistics (CSV + LaTeX)\n")
cat("Table 2: Completion Rates (CSV + LaTeX)\n")
cat("Arquivos em: output/tables/\n")
cat("==============================================================================\n\n")

cat("Script 03_descriptive_stats.R concluído com sucesso.\n\n")

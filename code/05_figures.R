#' ==============================================================================
#' Script: 05_figures.R
#' Projeto: Obra Transparente DiD Analysis
#' Descrição: Gera figuras do paper (event study plot, parallel trends)
#'
#' Inputs:
#'   - data/processed/event_study_results.rds
#'   - data/processed/model_event_study.rds
#'   - data/processed/analysis_completion.rds
#'
#' Outputs:
#'   - output/figures/fig1_event_study.png
#'   - output/figures/fig1_event_study.pdf
#'   - output/figures/fig2_completion_trends.png
#'   - output/figures/fig2_completion_trends.pdf
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
cat("05_figures.R - Gerando figuras\n")
cat("==============================================================================\n\n")

# Verificar working directory
stopifnot("Working directory incorreto" = basename(here()) == "did-obra-transparente")

# Tema para figuras
theme_paper <- theme_minimal() +
  theme(
    text = element_text(size = 11),
    axis.title = element_text(size = 12),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 10, color = "gray40"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# =============================================================================
# FIGURA 1: Event Study Plot
# =============================================================================
cat("1. Gerando Figura 1 (Event Study)...\n")

# Carregar resultados
event_study_results <- readRDS(here("data", "processed", "event_study_results.rds"))

# Adicionar período de referência (-1) com coeficiente 0
es_plot_data <- event_study_results %>%
  select(relative_period, estimate, ci_lower, ci_upper) %>%
  bind_rows(
    tibble(relative_period = -1, estimate = 0, ci_lower = 0, ci_upper = 0)
  ) %>%
  arrange(relative_period) %>%
  mutate(
    period_label = case_when(
      relative_period < 0 ~ paste0("t", relative_period),
      relative_period == 0 ~ "t (treatment)",
      TRUE ~ paste0("t+", relative_period)
    )
  )

# Criar figura
fig1 <- ggplot(es_plot_data, aes(x = relative_period, y = estimate)) +
  # Linha horizontal em zero
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  # Linha vertical no tratamento
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
  # Barras de erro (IC 95%)
  geom_errorbar(
    aes(ymin = ci_lower, ymax = ci_upper),
    width = 0.2,
    color = "steelblue",
    linewidth = 0.8
  ) +
  # Pontos
  geom_point(
    size = 3,
    color = "steelblue",
    fill = "white",
    shape = 21,
    stroke = 1.5
  ) +
  # Labels
  labs(
    title = "Event Study: Effect of CSO Monitoring on Construction Completion",
    subtitle = "Coefficients relative to treatment period (t-1 = reference)",
    x = "Period Relative to Treatment",
    y = "Effect on Completion Probability",
    caption = "Notes: 95% confidence intervals shown. Standard errors clustered at municipality level."
  ) +
  # Escala
  scale_x_continuous(breaks = seq(-4, 4, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  # Tema
  theme_paper +
  # Anotação
annotate(
    "text",
    x = -2.5, y = max(es_plot_data$ci_upper) * 0.9,
    label = "Pre-treatment\n(parallel trends)",
    size = 3, hjust = 0, color = "gray40"
  ) +
  annotate(
    "text",
    x = 1.5, y = max(es_plot_data$ci_upper) * 0.9,
    label = "Post-treatment\n(treatment effect)",
    size = 3, hjust = 0.5, color = "gray40"
  )

# Salvar
ggsave(
  here("output", "figures", "fig1_event_study.png"),
  fig1,
  width = 10, height = 6, dpi = 300
)
ggsave(
  here("output", "figures", "fig1_event_study.pdf"),
  fig1,
  width = 10, height = 6
)

cat("   Salvo: output/figures/fig1_event_study.png\n")
cat("   Salvo: output/figures/fig1_event_study.pdf\n")

# =============================================================================
# FIGURA 2: Completion Trends (Parallel Trends Visualization)
# =============================================================================
cat("\n2. Gerando Figura 2 (Completion Trends)...\n")

# Carregar dados de completion
completion_data <- readRDS(here("data", "processed", "analysis_completion.rds"))

# Formatar para plot
trends_data <- completion_data %>%
  mutate(
    period_num = ifelse(period == "baseline", 1, 2),
    group_label = ifelse(group == "Treatment",
                         "Participating (Treatment)",
                         "Non-participating (Control)")
  )

# Criar figura
fig2 <- ggplot(trends_data, aes(x = period_num, y = completion_rate,
                                 color = group_label, group = group_label)) +
  # Linhas
  geom_line(linewidth = 1.2) +
  # Pontos
  geom_point(size = 4) +
  # Labels dos pontos
  geom_text(
    aes(label = sprintf("%.0f%%", completion_rate * 100)),
    vjust = -1.5,
    size = 4,
    fontface = "bold"
  ) +
  # Cores
  scale_color_manual(
    values = c("Participating (Treatment)" = "#E41A1C",
               "Non-participating (Control)" = "#377EB8")
  ) +
  # Eixos
  scale_x_continuous(
    breaks = c(1, 2),
    labels = c("Aug 2017\n(Before Project)", "Aug 2019\n(After Project)")
  ) +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0.2, 0.7)
  ) +
  # Labels
  labs(
    title = "Construction Completion Rates by Participation Status",
    subtitle = "Before and after the Obra Transparente project",
    x = NULL,
    y = "Completion Rate",
    color = NULL,
    caption = "Source: SIMEC data. Sample: SP, MG, SC, PR, RS."
  ) +
  # Tema
  theme_paper +
  theme(
    legend.position = "top",
    axis.text.x = element_text(size = 11)
  )

# Salvar
ggsave(
  here("output", "figures", "fig2_completion_trends.png"),
  fig2,
  width = 8, height = 6, dpi = 300
)
ggsave(
  here("output", "figures", "fig2_completion_trends.pdf"),
  fig2,
  width = 8, height = 6
)

cat("   Salvo: output/figures/fig2_completion_trends.png\n")
cat("   Salvo: output/figures/fig2_completion_trends.pdf\n")

# =============================================================================
# FIGURA 3: Event Study usando iplot do fixest (alternativa)
# =============================================================================
cat("\n3. Gerando Figura 3 (Event Study - fixest iplot)...\n")

# Carregar modelo
model_es <- readRDS(here("data", "processed", "model_event_study.rds"))

# Salvar usando iplot
png(here("output", "figures", "fig3_event_study_fixest.png"),
    width = 10, height = 6, units = "in", res = 300)
iplot(model_es,
      main = "Event Study: CSO Monitoring Effect",
      xlab = "Period Relative to Treatment",
      ylab = "Effect on Completion Probability")
dev.off()

pdf(here("output", "figures", "fig3_event_study_fixest.pdf"),
    width = 10, height = 6)
iplot(model_es,
      main = "Event Study: CSO Monitoring Effect",
      xlab = "Period Relative to Treatment",
      ylab = "Effect on Completion Probability")
dev.off()

cat("   Salvo: output/figures/fig3_event_study_fixest.png\n")
cat("   Salvo: output/figures/fig3_event_study_fixest.pdf\n")

# Resumo -----------------------------------------------------------------------
cat("\n")
cat("==============================================================================\n")
cat("RESUMO - Figuras geradas\n")
cat("==============================================================================\n")
cat("Fig 1: Event Study (ggplot2)\n")
cat("Fig 2: Completion Trends\n")
cat("Fig 3: Event Study (fixest iplot)\n")
cat("Arquivos em: output/figures/\n")
cat("==============================================================================\n\n")

cat("Script 05_figures.R concluído com sucesso.\n\n")

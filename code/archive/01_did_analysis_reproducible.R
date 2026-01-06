#' ==============================================================================
#' Script: 01_did_analysis_reproducible.R
#' Descricao: Analise DiD usando APENAS dados reproduziveis/traceáveis
#'
#' Este script segue a lógica do Untitled.Rmd, usando apenas fontes conhecidas:
#'   - obras_inicio_projeto.Rdata (período 1 - maio 2017)
#'   - obras_fim_seg_fase.Rdata (período 4 - agosto 2019)
#'   - situacao obras_atual.xlsx (lista de obras tratadas)
#'
#' Autor: Manoel Galdino
#' Data: 2026-01-05
#' ==============================================================================

# Setup ----
library(tidyverse)
library(here)
library(readxl)
library(janitor)
library(fixest)

cat("\n")
cat("================================================================\n")
cat("  ANALISE DiD - DADOS REPRODUZIVEIS\n")
cat("================================================================\n")
cat("Data/Hora:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# =============================================================================
# PARTE 1: CRIAR PAINEL REPRODUZIVEL
# =============================================================================

cat("--- PARTE 1: Criacao do Painel ---\n\n")

# Carregar lista de obras tratadas ----
cat("Carregando lista de obras tratadas...\n")

df_cidades_ot <- read_excel(
  here("original", "data", "situacao obras_atual.xlsx"),
  sheet = "SIMEC-Mai17",
  skip = 1
) |>
  clean_names() |>
  filter(!is.na(id)) |>
  select(id, municipio, uf) |>
  mutate(indicator_ot = 1)

cat("  Obras tratadas:", nrow(df_cidades_ot), "\n")
cat("  Municipios tratados:", n_distinct(df_cidades_ot$municipio), "\n\n")

# Carregar periodo 1 (maio 2017) ----
cat("Carregando periodo 1 (Maio 2017)...\n")
load(here("original", "data", "obras_inicio_projeto.Rdata"))

p1 <- obras_inicio_projeto |>
  filter(uf %in% c("SP", "PR", "SC", "RS", "MG")) |>
  mutate(id = as.numeric(id)) |>
  left_join(
    df_cidades_ot |> mutate(id = as.numeric(id)),
    by = c("id", "municipio", "uf")
  ) |>
  mutate(
    indicator_ot = ifelse(is.na(indicator_ot), 0, indicator_ot),
    concluida = as.numeric(grepl("Concluída", situacao))
  ) |>
  group_by(municipio) |>
  mutate(indicator_muni_ot = max(indicator_ot)) |>
  ungroup() |>
  select(id, municipio, uf, concluida, indicator_muni_ot) |>
  mutate(periodo = 1)

cat("  Obras periodo 1:", nrow(p1), "\n")

# IDs validos para painel balanceado
ids_validos <- unique(p1$id)

# Carregar periodo 4 (agosto 2019) ----
cat("Carregando periodo 4 (Agosto 2019)...\n")
load(here("original", "data", "obras_fim_seg_fase.Rdata"))

p4 <- obras_fim_seg_fase |>
  filter(uf %in% c("SP", "PR", "SC", "RS", "MG")) |>
  mutate(id = as.numeric(id)) |>
  filter(id %in% ids_validos) |>  # Painel balanceado
  left_join(
    df_cidades_ot |> mutate(id = as.numeric(id)),
    by = c("id", "municipio", "uf")
  ) |>
  mutate(
    indicator_ot = ifelse(is.na(indicator_ot), 0, indicator_ot),
    concluida = as.numeric(grepl("Concluída", situacao))
  ) |>
  group_by(municipio) |>
  mutate(indicator_muni_ot = max(indicator_ot)) |>
  ungroup() |>
  select(id, municipio, uf, concluida, indicator_muni_ot) |>
  mutate(periodo = 4)

cat("  Obras periodo 4:", nrow(p4), "\n\n")

# Combinar em painel ----
did_panel <- bind_rows(p1, p4) |>
  rename(group_treated = indicator_muni_ot) |>
  mutate(
    post = as.numeric(periodo == 4),
    treat_post = group_treated * post
  ) |>
  arrange(id, periodo)

cat("Painel criado:\n")
cat("  Total observacoes:", nrow(did_panel), "\n")
cat("  Obras unicas:", n_distinct(did_panel$id), "\n")
cat("  Municipios:", n_distinct(did_panel$municipio), "\n")
cat("  Municipios tratados:", n_distinct(did_panel$municipio[did_panel$group_treated == 1]), "\n\n")

# Salvar painel
saveRDS(did_panel, here("data", "processed", "did_panel_reproducible.rds"))

# =============================================================================
# PARTE 2: ESTATISTICAS DESCRITIVAS
# =============================================================================

cat("--- PARTE 2: Estatisticas Descritivas ---\n\n")

# Tabela 2x2: Taxas de conclusao
cat("TAXAS DE CONCLUSAO:\n")
cat("--------------------------------------------------\n")

stats_2x2 <- did_panel |>
  group_by(group_treated, periodo) |>
  summarise(
    n = n(),
    concluidas = sum(concluida),
    pct = round(100 * mean(concluida), 1),
    .groups = "drop"
  )

# Formato tabela
p1_ctrl <- stats_2x2 |> filter(group_treated == 0, periodo == 1)
p1_trat <- stats_2x2 |> filter(group_treated == 1, periodo == 1)
p4_ctrl <- stats_2x2 |> filter(group_treated == 0, periodo == 4)
p4_trat <- stats_2x2 |> filter(group_treated == 1, periodo == 4)

cat(sprintf("                     |  Antes (2017)  |  Depois (2019)  |  Diferenca\n"))
cat(sprintf("---------------------|----------------|-----------------|------------\n"))
cat(sprintf("Controle (n=%d)    |     %5.1f%%     |      %5.1f%%      |   +%4.1f pp\n",
            p1_ctrl$n, p1_ctrl$pct, p4_ctrl$pct, p4_ctrl$pct - p1_ctrl$pct))
cat(sprintf("Tratados (n=%d)      |     %5.1f%%     |      %5.1f%%      |   +%4.1f pp\n",
            p1_trat$n, p1_trat$pct, p4_trat$pct, p4_trat$pct - p1_trat$pct))
cat(sprintf("---------------------|----------------|-----------------|------------\n"))

# Calcular DiD manualmente
did_manual <- (p4_trat$pct - p1_trat$pct) - (p4_ctrl$pct - p1_ctrl$pct)
cat(sprintf("DiD (diferenca das diferencas):                        %+5.1f pp\n\n", did_manual))

# =============================================================================
# PARTE 3: ANALISE DiD
# =============================================================================

cat("--- PARTE 3: Analise DiD ---\n\n")

# Modelo 1: DiD simples (OLS)
cat("MODELO 1: DiD Simples (OLS)\n")
model_ols <- lm(concluida ~ group_treated + post + treat_post, data = did_panel)
cat(sprintf("  ATT (treat_post): %.4f (%.4f)\n",
            coef(model_ols)["treat_post"],
            summary(model_ols)$coefficients["treat_post", "Std. Error"]))
cat(sprintf("  p-value: %.4f\n\n", summary(model_ols)$coefficients["treat_post", "Pr(>|t|)"]))

# Modelo 2: TWFE com efeitos fixos de obra e periodo
cat("MODELO 2: Two-Way Fixed Effects (obra + periodo)\n")
model_twfe <- feols(concluida ~ treat_post | id + periodo, data = did_panel, cluster = ~municipio)
cat(sprintf("  ATT (treat_post): %.4f (%.4f)\n",
            coef(model_twfe)["treat_post"],
            se(model_twfe)["treat_post"]))
cat(sprintf("  p-value: %.4f\n", pvalue(model_twfe)["treat_post"]))
cat(sprintf("  IC 95%%: [%.4f, %.4f]\n\n",
            coef(model_twfe)["treat_post"] - 1.96 * se(model_twfe)["treat_post"],
            coef(model_twfe)["treat_post"] + 1.96 * se(model_twfe)["treat_post"]))

# Modelo 3: TWFE cluster no municipio (mais conservador)
cat("MODELO 3: TWFE com cluster em municipio\n")
model_muni <- feols(concluida ~ treat_post | municipio + periodo, data = did_panel, cluster = ~municipio)
cat(sprintf("  ATT (treat_post): %.4f (%.4f)\n",
            coef(model_muni)["treat_post"],
            se(model_muni)["treat_post"]))
cat(sprintf("  p-value: %.4f\n", pvalue(model_muni)["treat_post"]))
cat(sprintf("  IC 95%%: [%.4f, %.4f]\n\n",
            coef(model_muni)["treat_post"] - 1.96 * se(model_muni)["treat_post"],
            coef(model_muni)["treat_post"] + 1.96 * se(model_muni)["treat_post"]))

# =============================================================================
# PARTE 4: RESUMO DOS ACHADOS
# =============================================================================

cat("================================================================\n")
cat("  RESUMO DOS ACHADOS PRINCIPAIS\n")
cat("================================================================\n\n")

cat("1. DADOS:\n")
cat(sprintf("   - %d obras em %d municipios\n", n_distinct(did_panel$id), n_distinct(did_panel$municipio)))
cat(sprintf("   - %d obras em %d municipios TRATADOS\n",
            n_distinct(did_panel$id[did_panel$group_treated == 1]),
            n_distinct(did_panel$municipio[did_panel$group_treated == 1])))
cat(sprintf("   - Periodo: Maio 2017 (antes) vs Agosto 2019 (depois)\n\n"))

cat("2. TAXAS DE CONCLUSAO:\n")
cat(sprintf("   - Tratados: %.1f%% -> %.1f%% (+%.1f pp)\n",
            p1_trat$pct, p4_trat$pct, p4_trat$pct - p1_trat$pct))
cat(sprintf("   - Controle: %.1f%% -> %.1f%% (+%.1f pp)\n\n",
            p1_ctrl$pct, p4_ctrl$pct, p4_ctrl$pct - p1_ctrl$pct))

cat("3. EFEITO DO TRATAMENTO (ATT):\n")
cat(sprintf("   - DiD manual: %+.1f pontos percentuais\n", did_manual))
cat(sprintf("   - TWFE (cluster municipio): %.3f (SE=%.3f, p=%.3f)\n",
            coef(model_muni)["treat_post"],
            se(model_muni)["treat_post"],
            pvalue(model_muni)["treat_post"]))

if(pvalue(model_muni)["treat_post"] < 0.05) {
  cat("   - RESULTADO: Efeito SIGNIFICATIVO a 5%\n\n")
} else if(pvalue(model_muni)["treat_post"] < 0.10) {
  cat("   - RESULTADO: Efeito SIGNIFICATIVO a 10%\n\n")
} else {
  cat("   - RESULTADO: Efeito NAO significativo\n\n")
}

cat("4. INTERPRETACAO:\n")
if(coef(model_muni)["treat_post"] < 0) {
  cat("   O projeto Obra Transparente teve efeito NEGATIVO na taxa de\n")
  cat("   conclusao de obras. Municipios tratados tiveram MENOR aumento\n")
  cat("   na taxa de conclusao comparados ao grupo controle.\n\n")
} else {
  cat("   O projeto Obra Transparente teve efeito POSITIVO na taxa de\n")
  cat("   conclusao de obras. Municipios tratados tiveram MAIOR aumento\n")
  cat("   na taxa de conclusao comparados ao grupo controle.\n\n")
}

cat("================================================================\n")
cat("  Analise concluida em:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("================================================================\n")

# Salvar resultados
results <- list(
  panel = did_panel,
  stats = stats_2x2,
  model_ols = model_ols,
  model_twfe = model_twfe,
  model_muni = model_muni,
  did_manual = did_manual
)
saveRDS(results, here("data", "processed", "did_results_reproducible.rds"))

sessionInfo()

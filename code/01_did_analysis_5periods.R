#' ==============================================================================
#' Script: 01_did_analysis_5periods.R
#' Descricao: Analise DiD com 5 periodos + Event Study (dados reproduziveis)
#'
#' Fontes de dados:
#'   - obras_inicio_projeto.Rdata (periodo 1 - maio 2017)
#'   - obras_08032018.csv (periodo 2 - marco 2018)
#'   - obras_upload28092018.csv (periodo 3 - setembro 2018)
#'   - obras_fim_seg_fase.Rdata (periodo 4 - agosto 2019)
#'   - simec 25-10-23 - simec.csv (periodo 5 - outubro 2023)
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
library(data.table)
library(fixest)

cat("\n")
cat("================================================================\n")
cat("  ANALISE DiD 5 PERIODOS + EVENT STUDY\n")
cat("================================================================\n")
cat("Data/Hora:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# =============================================================================
# PARTE 1: CRIAR PAINEL DE 5 PERIODOS
# =============================================================================

cat("--- PARTE 1: Criacao do Painel (5 periodos) ---\n\n")

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
  mutate(
    id = as.numeric(id),
    indicator_ot = 1
  )

cat("  Obras tratadas:", nrow(df_cidades_ot), "\n")
cat("  Municipios:", n_distinct(df_cidades_ot$municipio), "\n\n")

# Funcao para processar .Rdata (ja filtrado para Construcao) ----
process_rdata <- function(data, periodo, df_ot) {
  data |>
    filter(uf %in% c("SP", "PR", "SC", "RS", "MG")) |>
    mutate(id = as.numeric(id)) |>
    left_join(df_ot, by = c("id", "municipio", "uf")) |>
    mutate(
      indicator_ot = ifelse(is.na(indicator_ot), 0, indicator_ot),
      concluida = as.numeric(grepl("Concluída", situacao))
    ) |>
    group_by(municipio) |>
    mutate(indicator_muni_ot = max(indicator_ot)) |>
    ungroup() |>
    select(id, municipio, uf, concluida, indicator_muni_ot) |>
    mutate(periodo = periodo)
}

# Funcao para processar CSV (precisa filtrar tipo_da_obra) ----
process_csv <- function(filepath, periodo, df_ot, ids_validos = NULL) {

  # Ler CSV
  data <- fread(filepath, encoding = "UTF-8") |>
    clean_names()

  # Verificar nome da coluna de tipo de obra
  tipo_col <- intersect(names(data), c("tipo_da_obra", "tipo_de_obra", "tipo_obra"))

  if (length(tipo_col) > 0) {
    data <- data |> filter(get(tipo_col[1]) == "Construção")
  }

  result <- data |>
    filter(uf %in% c("SP", "PR", "SC", "RS", "MG")) |>
    mutate(id = as.numeric(id)) |>
    left_join(df_ot, by = c("id", "municipio", "uf")) |>
    mutate(
      indicator_ot = ifelse(is.na(indicator_ot), 0, indicator_ot),
      concluida = as.numeric(grepl("Concluída", situacao))
    ) |>
    group_by(municipio) |>
    mutate(indicator_muni_ot = max(indicator_ot)) |>
    ungroup()

  # Filtrar para painel balanceado se ids_validos fornecido
  if (!is.null(ids_validos)) {
    result <- result |> filter(id %in% ids_validos)
  }

  result |>
    select(id, municipio, uf, concluida, indicator_muni_ot) |>
    mutate(periodo = periodo)
}

# Processar periodo 1 (maio 2017) - .Rdata ----
cat("Processando Periodo 1 (Maio 2017)...\n")
load(here("original", "data", "obras_inicio_projeto.Rdata"))
p1 <- process_rdata(obras_inicio_projeto, 1, df_cidades_ot)
cat("  Obras:", nrow(p1), "\n")

# IDs validos para painel balanceado
ids_validos <- unique(p1$id)
cat("  IDs para painel balanceado:", length(ids_validos), "\n\n")

# Processar periodo 2 (marco 2018) - CSV ----
cat("Processando Periodo 2 (Marco 2018)...\n")
p2 <- process_csv(
  here("data", "raw", "simec_snapshots", "obras_08032018.csv"),
  2, df_cidades_ot, ids_validos
)
cat("  Obras:", nrow(p2), "\n")

# Processar periodo 3 (setembro 2018) - CSV ----
cat("Processando Periodo 3 (Setembro 2018)...\n")
p3 <- process_csv(
  here("data", "raw", "simec_snapshots", "obras_upload28092018.csv"),
  3, df_cidades_ot, ids_validos
)
cat("  Obras:", nrow(p3), "\n")

# Processar periodo 4 (agosto 2019) - .Rdata ----
cat("Processando Periodo 4 (Agosto 2019)...\n")
load(here("original", "data", "obras_fim_seg_fase.Rdata"))
p4 <- process_rdata(obras_fim_seg_fase, 4, df_cidades_ot) |>
  filter(id %in% ids_validos)
cat("  Obras:", nrow(p4), "\n")

# Processar periodo 5 (outubro 2023) - CSV ----
cat("Processando Periodo 5 (Outubro 2023)...\n")
p5 <- process_csv(
  here("data", "raw", "simec_snapshots", "simec 25-10-23 - simec.csv"),
  5, df_cidades_ot, ids_validos
)
cat("  Obras:", nrow(p5), "\n\n")

# Combinar todos os periodos ----
did_panel <- bind_rows(p1, p2, p3, p4, p5) |>
  rename(group_treated = indicator_muni_ot) |>
  mutate(
    # Tratamento comeca no periodo 3 (setembro 2018)
    post = as.numeric(periodo >= 3),
    treat_post = group_treated * post,
    # Para event study: periodos relativos ao tratamento
    # Tratamento em t=3, entao: t=1 -> -2, t=2 -> -1, t=3 -> 0, t=4 -> +1, t=5 -> +2
    rel_time = periodo - 3
  ) |>
  arrange(id, periodo)

cat("PAINEL CRIADO:\n")
cat("  Total observacoes:", nrow(did_panel), "\n")
cat("  Obras unicas:", n_distinct(did_panel$id), "\n")
cat("  Municipios:", n_distinct(did_panel$municipio), "\n")
cat("  Municipios tratados:", n_distinct(did_panel$municipio[did_panel$group_treated == 1]), "\n")
cat("  Periodos:", paste(sort(unique(did_panel$periodo)), collapse = ", "), "\n\n")

# Verificar balanceamento
cat("Obras por periodo:\n")
did_panel |>
  group_by(periodo) |>
  summarise(n = n()) |>
  print()

# Salvar painel
saveRDS(did_panel, here("data", "processed", "did_panel_5periods.rds"))

# =============================================================================
# PARTE 2: ESTATISTICAS DESCRITIVAS
# =============================================================================

cat("\n--- PARTE 2: Estatisticas Descritivas ---\n\n")

cat("TAXAS DE CONCLUSAO POR PERIODO E GRUPO:\n")
cat("--------------------------------------------------------\n")

stats <- did_panel |>
  group_by(periodo, group_treated) |>
  summarise(
    n = n(),
    concluidas = sum(concluida),
    pct = round(100 * mean(concluida), 1),
    .groups = "drop"
  ) |>
  pivot_wider(
    names_from = group_treated,
    values_from = c(n, concluidas, pct),
    names_glue = "{.value}_{group_treated}"
  )

cat(sprintf("\nPeriodo |   Controle   |   Tratados   | Diferenca\n"))
cat(sprintf("--------|--------------|--------------|----------\n"))

for (i in 1:nrow(stats)) {
  s <- stats[i, ]
  diff <- s$pct_1 - s$pct_0
  marker <- ifelse(s$periodo >= 3, " *", "")
  cat(sprintf("   %d%s   |    %5.1f%%    |    %5.1f%%    |  %+5.1f pp\n",
              s$periodo, marker, s$pct_0, s$pct_1, diff))
}
cat("--------------------------------------------------------\n")
cat("* Periodos pos-tratamento (>=3)\n\n")

# =============================================================================
# PARTE 3: DiD ESTATICO
# =============================================================================

cat("--- PARTE 3: DiD Estatico ---\n\n")

# Modelo TWFE
model_twfe <- feols(
  concluida ~ treat_post | id + periodo,
  data = did_panel,
  cluster = ~municipio
)

cat("MODELO TWFE (efeitos fixos: obra + periodo)\n")
cat(sprintf("  ATT: %.4f\n", coef(model_twfe)["treat_post"]))
cat(sprintf("  SE (cluster municipio): %.4f\n", se(model_twfe)["treat_post"]))
cat(sprintf("  t-stat: %.3f\n", coef(model_twfe)["treat_post"] / se(model_twfe)["treat_post"]))
cat(sprintf("  p-value: %.4f\n", pvalue(model_twfe)["treat_post"]))
cat(sprintf("  IC 95%%: [%.4f, %.4f]\n\n",
            coef(model_twfe)["treat_post"] - 1.96 * se(model_twfe)["treat_post"],
            coef(model_twfe)["treat_post"] + 1.96 * se(model_twfe)["treat_post"]))

# =============================================================================
# PARTE 4: EVENT STUDY
# =============================================================================

cat("--- PARTE 4: Event Study ---\n\n")

# Criar variaveis de interacao para event study
# Omitir periodo -1 (t=2) como referencia
did_panel <- did_panel |>
  mutate(
    # Interacoes tratamento x tempo relativo
    treat_m2 = group_treated * (rel_time == -2),  # t=1
    treat_m1 = group_treated * (rel_time == -1),  # t=2 (referencia, omitido)
    treat_0  = group_treated * (rel_time == 0),   # t=3
    treat_p1 = group_treated * (rel_time == 1),   # t=4
    treat_p2 = group_treated * (rel_time == 2)    # t=5
  )

# Event study model (omitindo t=-1 como referencia)
model_es <- feols(
  concluida ~ treat_m2 + treat_0 + treat_p1 + treat_p2 | id + periodo,
  data = did_panel,
  cluster = ~municipio
)

cat("EVENT STUDY (referencia: periodo -1, ou seja, t=2)\n")
cat("--------------------------------------------------------\n")
cat(sprintf("Periodo |  Coef.  |   SE    | p-value | Sig.\n"))
cat(sprintf("--------|---------|---------|---------|------\n"))

# Extrair coeficientes
es_coefs <- data.frame(
  periodo_rel = c(-2, 0, 1, 2),
  periodo_abs = c(1, 3, 4, 5),
  coef = c(coef(model_es)["treat_m2"], coef(model_es)["treat_0"],
           coef(model_es)["treat_p1"], coef(model_es)["treat_p2"]),
  se = c(se(model_es)["treat_m2"], se(model_es)["treat_0"],
         se(model_es)["treat_p1"], se(model_es)["treat_p2"]),
  pval = c(pvalue(model_es)["treat_m2"], pvalue(model_es)["treat_0"],
           pvalue(model_es)["treat_p1"], pvalue(model_es)["treat_p2"])
)

es_coefs$sig <- ifelse(es_coefs$pval < 0.01, "***",
                       ifelse(es_coefs$pval < 0.05, "**",
                              ifelse(es_coefs$pval < 0.10, "*", "")))

# Adicionar referencia (t=-1)
es_coefs <- bind_rows(
  es_coefs[1, ],
  data.frame(periodo_rel = -1, periodo_abs = 2, coef = 0, se = NA, pval = NA, sig = "(ref)"),
  es_coefs[2:4, ]
) |>
  arrange(periodo_rel)

for (i in 1:nrow(es_coefs)) {
  r <- es_coefs[i, ]
  if (r$periodo_rel == -1) {
    cat(sprintf("  %+d    |  0.000  |   ---   |   ---   | (ref)\n", r$periodo_rel))
  } else {
    cat(sprintf("  %+d    | %+.4f | %.4f  |  %.3f  | %s\n",
                r$periodo_rel, r$coef, r$se, r$pval, r$sig))
  }
}
cat("--------------------------------------------------------\n")
cat("Significancia: * p<0.10, ** p<0.05, *** p<0.01\n\n")

# Teste de tendencias paralelas (pre-treatment)
cat("TESTE DE TENDENCIAS PARALELAS:\n")
cat(sprintf("  Coef. t=-2: %.4f (p=%.3f)\n",
            coef(model_es)["treat_m2"], pvalue(model_es)["treat_m2"]))
if (pvalue(model_es)["treat_m2"] > 0.10) {
  cat("  -> Nao rejeita H0: tendencias paralelas pre-tratamento\n\n")
} else {
  cat("  -> ATENCAO: Rejeita tendencias paralelas (p<0.10)\n\n")
}

# =============================================================================
# PARTE 5: RESUMO DOS ACHADOS
# =============================================================================

cat("================================================================\n")
cat("  RESUMO DOS ACHADOS PRINCIPAIS\n")
cat("================================================================\n\n")

cat("1. DADOS:\n")
cat(sprintf("   - %d obras em %d municipios (painel balanceado)\n",
            n_distinct(did_panel$id), n_distinct(did_panel$municipio)))
cat(sprintf("   - %d obras em %d municipios TRATADOS\n",
            n_distinct(did_panel$id[did_panel$group_treated == 1]),
            n_distinct(did_panel$municipio[did_panel$group_treated == 1])))
cat("   - 5 periodos: Mai/17, Mar/18, Set/18, Ago/19, Out/23\n")
cat("   - Tratamento inicia em Set/2018 (periodo 3)\n\n")

cat("2. DiD ESTATICO:\n")
cat(sprintf("   - ATT: %+.3f (%.3f), p=%.3f\n",
            coef(model_twfe)["treat_post"],
            se(model_twfe)["treat_post"],
            pvalue(model_twfe)["treat_post"]))
if (pvalue(model_twfe)["treat_post"] < 0.05) {
  cat("   - Efeito SIGNIFICATIVO a 5%\n\n")
} else if (pvalue(model_twfe)["treat_post"] < 0.10) {
  cat("   - Efeito SIGNIFICATIVO a 10%\n\n")
} else {
  cat("   - Efeito NAO significativo\n\n")
}

cat("3. EVENT STUDY:\n")
cat("   Coeficientes (ref: t=-1):\n")
for (i in 1:nrow(es_coefs)) {
  r <- es_coefs[i, ]
  if (r$periodo_rel == -1) {
    cat(sprintf("   - t=%+d: 0.000 (referencia)\n", r$periodo_rel))
  } else {
    cat(sprintf("   - t=%+d: %+.3f %s\n", r$periodo_rel, r$coef, r$sig))
  }
}

cat("\n4. INTERPRETACAO:\n")
if (pvalue(model_es)["treat_m2"] > 0.10) {
  cat("   - Tendencias paralelas: OK (pre-trends nao significativos)\n")
} else {
  cat("   - ATENCAO: Possivel violacao de tendencias paralelas\n")
}

if (coef(model_twfe)["treat_post"] > 0) {
  cat("   - Direcao do efeito: POSITIVO (tratamento aumenta conclusao)\n")
} else {
  cat("   - Direcao do efeito: NEGATIVO (tratamento reduz conclusao)\n")
}

if (pvalue(model_twfe)["treat_post"] < 0.10) {
  cat(sprintf("   - Magnitude: %.1f pontos percentuais\n",
              100 * coef(model_twfe)["treat_post"]))
} else {
  cat("   - Magnitude: Efeito nao distinguivel de zero\n")
}

cat("\n================================================================\n")
cat("  Analise concluida em:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("================================================================\n")

# Salvar resultados
results <- list(
  panel = did_panel,
  stats = stats,
  model_twfe = model_twfe,
  model_es = model_es,
  es_coefs = es_coefs
)
saveRDS(results, here("data", "processed", "did_results_5periods.rds"))

sessionInfo()

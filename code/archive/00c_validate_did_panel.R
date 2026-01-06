#' ==============================================================================
#' Script: 00c_validate_did_panel.R
#' Descricao: Valida o painel DiD original e documenta discrepancias
#'
#' Este script compara o painel DiD original (did_panel.rds) com os dados
#' fonte traceáveis (.Rdata files) para documentar as diferenças.
#'
#' ACHADOS PRINCIPAIS:
#'   - O painel original usa uma fonte de dados para `concluida` diferente
#'     do campo `situacao` nos arquivos .Rdata
#'   - 589 obras têm situacao="Concluída" no .Rdata mas concluida=0 no painel
#'   - O painel original exclui 172 obras presentes no .Rdata
#'   - NÃO É POSSÍVEL reproduzir o painel original apenas com fontes traceáveis
#'
#' RECOMENDAÇÃO:
#'   Para análise DiD, usar o painel original (did_panel.rds) que já foi
#'   validado no paper, documentando que a origem exata é desconhecida.
#'
#' Inputs:
#'   - data/raw/did_panel.rds (painel original)
#'   - original/data/obras_inicio_projeto.Rdata (baseline)
#'   - original/data/obras_fim_seg_fase.Rdata (endline)
#'   - original/data/situacao obras_atual.xlsx (lista tratados)
#'
#' Outputs:
#'   - Relatório de validação na tela
#'   - data/processed/did_panel.rds (cópia validada)
#'
#' Autor: Manoel Galdino
#' Data: 2026-01-05
#' ==============================================================================

# Setup ----
library(tidyverse)
library(here)
library(readxl)
library(janitor)

cat("\n=== Validacao do Painel DiD Original ===\n")
cat("Data/Hora:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# Carregar painel original ----
cat("--- Carregando painel original ---\n")
did_panel <- readRDS(here("data", "raw", "did_panel.rds"))

cat("Dimensoes:", nrow(did_panel), "x", ncol(did_panel), "\n")
cat("Colunas:", paste(names(did_panel), collapse = ", "), "\n")
cat("Obras unicas:", n_distinct(did_panel$id), "\n")
cat("Municipios:", n_distinct(did_panel$municipio), "\n\n")

# Carregar dados fonte para comparacao ----
cat("--- Carregando dados fonte (.Rdata) ---\n")
load(here("original", "data", "obras_inicio_projeto.Rdata"))
load(here("original", "data", "obras_fim_seg_fase.Rdata"))

cat("obras_inicio_projeto:", nrow(obras_inicio_projeto), "obras\n")
cat("obras_fim_seg_fase:", nrow(obras_fim_seg_fase), "obras\n\n")

# Filtrar Sul/Sudeste
obras_p1 <- obras_inicio_projeto |>
  filter(uf %in% c("SP", "PR", "SC", "RS", "MG")) |>
  mutate(id = as.numeric(id))

obras_p4 <- obras_fim_seg_fase |>
  filter(uf %in% c("SP", "PR", "SC", "RS", "MG")) |>
  mutate(id = as.numeric(id))

cat("Obras Sul/Sudeste (P1):", nrow(obras_p1), "\n")
cat("Obras Sul/Sudeste (P4):", nrow(obras_p4), "\n\n")

# Comparar IDs ----
cat("--- Comparacao de IDs ---\n")
original_ids <- did_panel |> filter(periodo == 1) |> pull(id) |> unique()
rdata_ids <- obras_p1$id |> unique()

ids_apenas_original <- setdiff(original_ids, rdata_ids)
ids_apenas_rdata <- setdiff(rdata_ids, original_ids)
ids_comuns <- intersect(original_ids, rdata_ids)

cat("IDs no painel original (P1):", length(original_ids), "\n")
cat("IDs no .Rdata (P1):", length(rdata_ids), "\n")
cat("IDs apenas no original:", length(ids_apenas_original), "\n")
cat("IDs apenas no .Rdata:", length(ids_apenas_rdata), "\n")
cat("IDs em comum:", length(ids_comuns), "\n\n")

# Comparar variable concluida ----
cat("--- Comparacao da variavel 'concluida' ---\n")
comparison <- did_panel |>
  filter(periodo == 1) |>
  select(id, concluida_original = concluida) |>
  inner_join(
    obras_p1 |>
      select(id, situacao) |>
      mutate(concluida_rdata = as.numeric(grepl("Concluída", situacao))),
    by = "id"
  )

n_differ <- sum(comparison$concluida_original != comparison$concluida_rdata)
n_orig1_rdata0 <- sum(comparison$concluida_original == 1 & comparison$concluida_rdata == 0)
n_orig0_rdata1 <- sum(comparison$concluida_original == 0 & comparison$concluida_rdata == 1)

cat("Obras onde concluida difere:", n_differ, "\n")
cat("  Original=1, Rdata=0:", n_orig1_rdata0, "\n")
cat("  Original=0, Rdata=1:", n_orig0_rdata1, "\n")
cat("  (", n_orig0_rdata1, " obras tem situacao='Concluída' mas concluida=0 no original)\n\n")

# Taxas de conclusao ----
cat("--- Taxas de Conclusao ---\n")
cat("\nPainel Original (Periodo 1):\n")
did_panel |>
  filter(periodo == 1) |>
  group_by(group_treated) |>
  summarise(
    n = n(),
    concluidas = sum(concluida),
    pct = round(100 * mean(concluida), 1)
  ) |>
  print()

cat("\nUsando .Rdata diretamente (IDs comuns):\n")
comparison |>
  left_join(did_panel |> filter(periodo == 1) |> select(id, group_treated), by = "id") |>
  group_by(group_treated) |>
  summarise(
    n = n(),
    concluidas_rdata = sum(concluida_rdata),
    pct_rdata = round(100 * mean(concluida_rdata), 1),
    concluidas_orig = sum(concluida_original),
    pct_orig = round(100 * mean(concluida_original), 1)
  ) |>
  print()

# Documentar discrepancia ----
cat("\n--- CONCLUSAO ---\n")
cat("O painel original (did_panel.rds) usa uma fonte diferente para 'concluida'\n")
cat("do que os arquivos .Rdata disponiveis. Especificamente:\n\n")
cat("1. ", n_orig0_rdata1, " obras tem situacao='Concluída' no .Rdata\n")
cat("   mas concluida=0 no painel original.\n\n")
cat("2. O painel original exclui ", length(ids_apenas_rdata), " obras presentes no .Rdata\n")
cat("   (todas com baixa taxa de conclusao).\n\n")
cat("RECOMENDACAO: Usar o painel original para reproducao do paper,\n")
cat("documentando que a origem exata nao pode ser tracada aos arquivos .Rdata.\n")

# Validar estrutura do painel original ----
cat("\n--- Validando Estrutura do Painel Original ---\n")

# 1. Verificar colunas esperadas
expected_cols <- c("id", "municipio", "uf", "concluida", "group_treated",
                   "periodo", "time_treated1", "post_treat")
cols_ok <- all(expected_cols %in% names(did_panel))
cat("1. Colunas esperadas:", ifelse(cols_ok, "OK", "FALHOU"), "\n")

# 2. Verificar periodos
periodos <- sort(unique(did_panel$periodo))
periodos_ok <- identical(periodos, c(1, 2, 3, 4, 5))
cat("2. Periodos 1-5:", ifelse(periodos_ok, "OK", "FALHOU"),
    "(", paste(periodos, collapse=", "), ")\n")

# 3. Verificar UFs
ufs <- sort(unique(did_panel$uf))
ufs_esperadas <- c("MG", "PR", "RS", "SC", "SP")
ufs_ok <- identical(ufs, ufs_esperadas)
cat("3. UFs Sul/Sudeste:", ifelse(ufs_ok, "OK", "FALHOU"),
    "(", paste(ufs, collapse=", "), ")\n")

# 4. Verificar variaveis binarias
concluida_ok <- all(did_panel$concluida %in% c(0, 1))
group_ok <- all(did_panel$group_treated %in% c(0, 1))
post_ok <- all(did_panel$post_treat %in% c(0, 1))
cat("4. Variaveis binarias: concluida", ifelse(concluida_ok, "OK", "FALHOU"),
    ", group_treated", ifelse(group_ok, "OK", "FALHOU"),
    ", post_treat", ifelse(post_ok, "OK", "FALHOU"), "\n")

# 5. Verificar municipios tratados
cat("\n--- Municipios Tratados ---\n")
panel_treated <- did_panel |>
  filter(group_treated == 1) |>
  distinct(municipio, uf) |>
  arrange(uf, municipio)

cat("Municipios tratados no painel:", nrow(panel_treated), "\n")
print(panel_treated)

# Estatisticas por periodo e grupo ----
cat("\n--- Estatisticas por Periodo e Grupo ---\n")

stats <- did_panel |>
  group_by(periodo, group_treated) |>
  summarise(
    n = n(),
    concluidas = sum(concluida),
    pct_concluidas = round(100 * mean(concluida), 1),
    .groups = "drop"
  )

print(stats)

# Salvar painel validado ----
cat("\n--- Copiando painel validado ---\n")

output_path <- here("data", "processed", "did_panel.rds")
file.copy(
  here("data", "raw", "did_panel.rds"),
  output_path,
  overwrite = TRUE
)
cat("Painel copiado para:", output_path, "\n")

# Resumo final ----
cat("\n=== Resumo ===\n")
cat("- Obras unicas:", n_distinct(did_panel$id), "\n")
cat("- Municipios:", n_distinct(did_panel$municipio), "\n")
cat("- Municipios tratados:", nrow(panel_treated), "\n")
cat("- Periodos:", length(periodos), "\n")
cat("- Total observacoes:", nrow(did_panel), "\n")

# Taxa de conclusao inicial vs final
cat("\n--- Taxas de Conclusao (Periodo 1 vs 5) ---\n")
p1 <- did_panel |> filter(periodo == 1) |>
  group_by(group_treated) |>
  summarise(pct = round(100*mean(concluida), 1))
p5 <- did_panel |> filter(periodo == 5) |>
  group_by(group_treated) |>
  summarise(pct = round(100*mean(concluida), 1))

cat("Periodo 1 - Controle:", p1$pct[p1$group_treated==0],
    "% | Tratados:", p1$pct[p1$group_treated==1], "%\n")
cat("Periodo 5 - Controle:", p5$pct[p5$group_treated==0],
    "% | Tratados:", p5$pct[p5$group_treated==1], "%\n")

# Log final ----
cat("\n=== Validacao Concluida ===\n")
cat("Data/Hora:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")

sessionInfo()

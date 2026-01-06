#' ==============================================================================
#' Script: 00b_process_simec_snapshots.R
#' Descricao: Processa snapshots SIMEC (CSV) e salva como .Rdata
#'
#' Este script le os arquivos CSV originais do SIMEC, padroniza as variaveis
#' e salva em formato .Rdata para uso posterior.
#'
#' Inputs:
#'   - data/raw/simec_snapshots/obras30052017.csv (periodo 1)
#'   - data/raw/simec_snapshots/obras_08032018.csv (periodo 2)
#'   - data/raw/simec_snapshots/obras_upload28092018.csv (periodo 3)
#'   - data/raw/simec_snapshots/obras2019_08_16.csv (periodo 4)
#'   - data/raw/simec_snapshots/simec 25-10-23 - simec.csv (periodo 5)
#'
#' Outputs:
#'   - data/processed/simec_2017_05.Rdata
#'   - data/processed/simec_2018_03.Rdata
#'   - data/processed/simec_2018_09.Rdata
#'   - data/processed/simec_2019_08.Rdata
#'   - data/processed/simec_2023_10.Rdata
#'
#' Autor: Manoel Galdino
#' Data: 2026-01-05
#' ==============================================================================

# Setup ----
library(tidyverse)
library(here)
library(janitor)

cat("\n=== Processamento de Snapshots SIMEC ===\n")
cat("Data/Hora:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

# Definir mapeamento de arquivos ----
snapshots <- tibble::tribble(
  ~periodo, ~arquivo_entrada, ~arquivo_saida, ~data_snapshot, ~descricao,
  1, "obras30052017.csv", "simec_2017_05.Rdata", "2017-05-30", "Maio 2017 (baseline)",
  2, "obras_08032018.csv", "simec_2018_03.Rdata", "2018-03-08", "Marco 2018",
  3, "obras_upload28092018.csv", "simec_2018_09.Rdata", "2018-09-28", "Setembro 2018",
  4, "obras2019_08_16.csv", "simec_2019_08.Rdata", "2019-08-16", "Agosto 2019",
  5, "simec 25-10-23 - simec.csv", "simec_2023_10.Rdata", "2023-10-25", "Outubro 2023"
)

# Funcao para detectar delimitador ----
detect_delimiter <- function(filepath) {
  first_line <- readLines(filepath, n = 1, encoding = "UTF-8")
  n_semicolons <- str_count(first_line, ";")
  n_commas <- str_count(first_line, ",")
  if (n_semicolons > n_commas) return(";") else return(",")
}

# Funcao para processar um snapshot ----
process_simec_snapshot <- function(input_file, output_file, periodo, data_snapshot) {

  input_path <- here("data", "raw", "simec_snapshots", input_file)
  output_path <- here("data", "processed", output_file)

  cat(sprintf("\nProcessando periodo %d: %s\n", periodo, input_file))

  # Detectar delimitador
  delim <- detect_delimiter(input_path)
  cat(sprintf("  Delimitador detectado: '%s'\n", delim))

  # Ler CSV com encoding correto e delimitador detectado
  simec <- read_delim(
    input_path,
    delim = delim,
    locale = locale(encoding = "UTF-8"),
    show_col_types = FALSE
  ) |>
    # Limpar nomes das colunas
    clean_names() |>
    # Selecionar e renomear colunas principais
    select(
      id_obra = id,
      nome,
      situacao,
      municipio,
      uf,
      cep,
      percentual_execucao = percentual_de_execucao,
      data_prevista_conclusao = data_prevista_de_conclusao_da_obra,
      tipo_projeto = tipo_do_projeto,
      tipo_obra = tipo_da_obra,
      classificacao_obra = classificacao_da_obra,
      valor_pactuado_fnde = valor_pactuado_com_o_fnde,
      rede_ensino = rede_de_ensino_publico,
      data_assinatura_contrato = data_de_assinatura_do_contrato,
      valor_contrato = valor_do_contrato,
      total_pago
    ) |>
    # Adicionar metadados do periodo
    mutate(
      periodo = periodo,
      data_snapshot = as.Date(data_snapshot)
    ) |>
    # Padronizar tipos
    mutate(
      id_obra = as.character(id_obra),
      cep = as.character(cep),
      percentual_execucao = as.numeric(percentual_execucao),
      valor_pactuado_fnde = as.numeric(valor_pactuado_fnde),
      valor_contrato = as.numeric(valor_contrato),
      total_pago = as.numeric(total_pago)
    ) |>
    # Padronizar situacao
    mutate(
      situacao_padrao = case_when(
        str_detect(situacao, regex("conclu", ignore_case = TRUE)) ~ "Concluida",
        str_detect(situacao, regex("execu|andamento", ignore_case = TRUE)) ~ "Em execucao",
        str_detect(situacao, regex("paralisa", ignore_case = TRUE)) ~ "Paralisada",
        str_detect(situacao, regex("cancel", ignore_case = TRUE)) ~ "Cancelada",
        str_detect(situacao, regex("n.o iniciada|nao iniciada", ignore_case = TRUE)) ~ "Nao iniciada",
        str_detect(situacao, regex("inacabada", ignore_case = TRUE)) ~ "Inacabada",
        TRUE ~ situacao
      )
    )

  # Salvar como Rdata
  save(simec, file = output_path)

  # Estatisticas
  n_obras <- nrow(simec)
  n_municipios <- n_distinct(simec$municipio)
  n_concluidas <- sum(simec$situacao_padrao == "Concluida", na.rm = TRUE)
  pct_concluidas <- round(100 * n_concluidas / n_obras, 1)

  cat(sprintf("  - N obras: %d\n", n_obras))
  cat(sprintf("  - N municipios: %d\n", n_municipios))
  cat(sprintf("  - Concluidas: %d (%.1f%%)\n", n_concluidas, pct_concluidas))
  cat(sprintf("  - Salvo em: %s\n", output_path))

  return(list(
    periodo = periodo,
    n_obras = n_obras,
    n_municipios = n_municipios,
    n_concluidas = n_concluidas,
    pct_concluidas = pct_concluidas
  ))
}

# Processar todos os snapshots ----
cat("--- Iniciando processamento ---\n")

resultados <- list()

for (i in 1:nrow(snapshots)) {
  s <- snapshots[i, ]
  resultados[[i]] <- process_simec_snapshot(
    input_file = s$arquivo_entrada,
    output_file = s$arquivo_saida,
    periodo = s$periodo,
    data_snapshot = s$data_snapshot
  )
}

# Resumo final ----
cat("\n=== Resumo do Processamento ===\n\n")

resumo <- bind_rows(resultados) |>
  left_join(snapshots |> select(periodo, descricao), by = "periodo")

cat("Periodo | Descricao              | N Obras | Concluidas\n")
cat("--------|------------------------|---------|------------\n")
for (i in 1:nrow(resumo)) {
  r <- resumo[i, ]
  cat(sprintf("   %d    | %-22s | %7d | %5d (%.1f%%)\n",
              r$periodo, r$descricao, r$n_obras, r$n_concluidas, r$pct_concluidas))
}

# Verificar arquivos gerados ----
cat("\n--- Arquivos gerados ---\n")
arquivos_gerados <- list.files(here("data", "processed"), pattern = "simec_.*\\.Rdata")
for (f in arquivos_gerados) {
  size_kb <- round(file.size(here("data", "processed", f)) / 1024, 0)
  cat(sprintf("  - %s (%d KB)\n", f, size_kb))
}

# Log final ----
cat("\n=== Processamento Concluido ===\n")
cat("Data/Hora:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")

sessionInfo()

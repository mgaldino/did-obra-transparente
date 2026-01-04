#' ==============================================================================
#' Script: 01_load_data.R
#' Projeto: Obra Transparente DiD Analysis
#' Descrição: Carrega todos os dados brutos e salva em formato processado
#'
#' Inputs:
#'   - data/raw/did_panel.rds
#'   - data/raw/municipal_covariates.rds
#'   - data/raw/simec_2017_08.Rdata
#'   - data/raw/simec_2019_08.Rdata
#'   - data/raw/treated_municipalities.csv
#'
#' Outputs:
#'   - data/processed/did_panel.rds
#'   - data/processed/municipal_covariates.rds
#'   - data/processed/simec_baseline.rds
#'   - data/processed/simec_endline.rds
#'   - data/processed/treated_municipalities.rds
#'
#' Autor: Manoel Galdino
#' Data: 2026-01-04
#' ==============================================================================

# Setup ------------------------------------------------------------------------
library(tidyverse)
library(here)

cat("\n")
cat("==============================================================================\n")
cat("01_load_data.R - Carregando dados brutos\n")
cat("==============================================================================\n\n")

# Verificar working directory
stopifnot("Working directory incorreto" = basename(here()) == "did-obra-transparente")
cat("Working directory:", here(), "\n\n")

# 1. Carregar lista de municípios tratados -------------------------------------
cat("1. Carregando lista de municípios tratados...\n")

treated_municipalities <- read_csv(
  here("data", "raw", "treated_municipalities.csv"),
  col_types = cols(
    municipio = col_character(),
    uf = col_character(),
    treated = col_double(),
    project_name = col_character(),
    start_date = col_date(),
    end_date = col_date()
  )
)

cat("   N municípios tratados:", nrow(treated_municipalities), "\n")
stopifnot("Deve haver 21 municípios tratados" = nrow(treated_municipalities) == 21)

# 2. Carregar painel DiD -------------------------------------------------------
cat("\n2. Carregando painel DiD...\n")

did_panel <- readRDS(here("data", "raw", "did_panel.rds"))

cat("   Dimensões:", nrow(did_panel), "x", ncol(did_panel), "\n")
cat("   N municípios:", n_distinct(did_panel$municipio), "\n")
cat("   N períodos:", n_distinct(did_panel$periodo), "\n")
cat("   N tratados:", n_distinct(did_panel$municipio[did_panel$group_treated == 1]), "\n")

# Validação
stopifnot("Períodos devem ser 1-5" = all(1:5 %in% did_panel$periodo))
stopifnot("21 municípios tratados" = n_distinct(did_panel$municipio[did_panel$group_treated == 1]) == 21)

# 3. Carregar covariáveis municipais -------------------------------------------
cat("\n3. Carregando covariáveis municipais...\n")

municipal_covariates <- readRDS(here("data", "raw", "municipal_covariates.rds"))

cat("   Dimensões:", nrow(municipal_covariates), "x", ncol(municipal_covariates), "\n")
cat("   Estados:", paste(sort(unique(municipal_covariates$uf)), collapse = ", "), "\n")

# 4. Carregar snapshots SIMEC --------------------------------------------------
cat("\n4. Carregando snapshots SIMEC...\n")

# Baseline (agosto 2017)
load(here("data", "raw", "simec_2017_08.Rdata"))
simec_baseline <- obras_inicio_projeto %>%
  as_tibble() %>%
  mutate(
    snapshot_date = as.Date("2017-08-01"),
    concluida = grepl("Concluída", situacao)
  )
rm(obras_inicio_projeto)

cat("   Baseline (ago/2017):", nrow(simec_baseline), "obras\n")

# Endline (agosto 2019)
load(here("data", "raw", "simec_2019_08.Rdata"))
simec_endline <- obras_fim_seg_fase %>%
  as_tibble() %>%
  mutate(
    snapshot_date = as.Date("2019-08-01"),
    concluida = grepl("Concluída", situacao)
  )
rm(obras_fim_seg_fase)

cat("   Endline (ago/2019):", nrow(simec_endline), "obras\n")

# 5. Salvar dados processados --------------------------------------------------
cat("\n5. Salvando dados processados...\n")

saveRDS(treated_municipalities, here("data", "processed", "treated_municipalities.rds"))
saveRDS(did_panel, here("data", "processed", "did_panel.rds"))
saveRDS(municipal_covariates, here("data", "processed", "municipal_covariates.rds"))
saveRDS(simec_baseline, here("data", "processed", "simec_baseline.rds"))
saveRDS(simec_endline, here("data", "processed", "simec_endline.rds"))

cat("   Arquivos salvos em data/processed/\n")

# Resumo -----------------------------------------------------------------------
cat("\n")
cat("==============================================================================\n")
cat("RESUMO - Dados carregados\n")
cat("==============================================================================\n")
cat("Municípios tratados:     ", nrow(treated_municipalities), "\n")
cat("Painel DiD:              ", nrow(did_panel), "obs x", ncol(did_panel), "vars\n")
cat("Covariáveis municipais:  ", nrow(municipal_covariates), "municípios\n")
cat("SIMEC baseline:          ", nrow(simec_baseline), "obras\n")
cat("SIMEC endline:           ", nrow(simec_endline), "obras\n")
cat("==============================================================================\n\n")

# Limpar ambiente
rm(list = setdiff(ls(), c("treated_municipalities", "did_panel", "municipal_covariates",
                          "simec_baseline", "simec_endline")))

cat("Script 01_load_data.R concluído com sucesso.\n\n")

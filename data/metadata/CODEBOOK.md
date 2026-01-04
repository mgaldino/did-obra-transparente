# Codebook - Obra Transparente DiD Analysis

**Data**: 2026-01-04
**Projeto**: Replication package for "The Civil Society Organizations effect" (Galdino et al., 2024)

---

## Visão Geral dos Dados

Este pacote de replicação contém dados para análise de diferenças-em-diferenças (DiD) do impacto do projeto Obra Transparente na conclusão de obras públicas de escolas e creches no Brasil.

### Fontes de Dados

| Fonte | Descrição | Acesso |
|-------|-----------|--------|
| SIMEC/FNDE | Sistema Integrado de Monitoramento, Execução e Controle | Snapshots mantidos por Transparência Brasil |
| IPEA | Instituto de Pesquisa Econômica Aplicada | Via pacote R `ipeadatar` |
| IBGE | Instituto Brasileiro de Geografia e Estatística | Via pacotes R `geobr` e `ribge` |
| Transparência Brasil | ONG responsável pelo projeto | Dados de monitoramento do projeto |

### Período de Análise

- **Baseline**: Agosto 2017 (antes do projeto)
- **Endline**: Agosto 2019 (após o projeto)
- **Projeto Obra Transparente**: Maio 2017 - Junho 2019

### Cobertura Geográfica

Estados incluídos na análise: SP, MG, SC, PR, RS (Sul e Sudeste)

---

## Arquivos de Dados

### 1. did_panel.rds

**Descrição**: Dataset principal para análise DiD. Painel de obras em 5 períodos.

**Fonte original**: Processado por Transparência Brasil a partir de snapshots do SIMEC

**Nota sobre processamento**: Este arquivo foi pré-processado pela equipe da Transparência Brasil. O processo exato de criação não está documentado nos scripts originais, mas acredita-se que foi gerado a partir dos snapshots do SIMEC em diferentes momentos.

**Dimensões**: 22,609 linhas × 8 colunas

**Unidade de observação**: Obra × Período

| Variável | Tipo | Descrição | Valores |
|----------|------|-----------|---------|
| `id` | character | Identificador único da obra no SIMEC | Ex: "1366" |
| `municipio` | character | Nome do município | Ex: "Conchas" |
| `uf` | character | Sigla do estado | SP, MG, SC, PR, RS |
| `concluida` | numeric | Obra concluída neste período | 0 = Não, 1 = Sim |
| `group_treated` | numeric | Município no grupo tratado | 0 = Controle, 1 = Tratado |
| `periodo` | numeric | Período do painel | 1, 2, 3, 4, 5 |
| `time_treated1` | numeric | Timing do tratamento (para event study) | 3 se tratado, 0 caso contrário |
| `post_treat` | numeric | Interação tratamento × pós | 0 ou 1 |

**Notas**:
- Período 3 marca o início do tratamento (maio 2017)
- `post_treat = group_treated * (periodo >= 3)`

---

### 2. municipal_covariates.rds

**Descrição**: Características socioeconômicas dos municípios para análise de balanceamento.

**Fonte**: IPEA (Atlas do Desenvolvimento Humano) via pacote `ipeadatar`

**Ano de referência**: Censo 2010

**Dimensões**: 2,038 linhas × 16 colunas

**Unidade de observação**: Município

| Variável | Tipo | Descrição | Unidade |
|----------|------|-----------|---------|
| `idhm` | numeric | Índice de Desenvolvimento Humano Municipal | 0-1 |
| `tcode` | integer | Código IBGE do município | 7 dígitos |
| `name_muni` | character | Nome do município (geobr) | - |
| `abbrev_state` | character | Sigla do estado | - |
| `ext_pobres` | numeric | % da população abaixo da linha de pobreza | % |
| `rpc` | numeric | Renda per capita | R$ |
| `ext_prop_pobres` | numeric | Proporção de pobres (linha de pobreza) | % |
| `p10_ricos_desigualdade` | numeric | Participação dos 10% mais ricos na renda | % |
| `freq_escola_15_1` | numeric | Taxa de frequência escolar (15-17 anos) | % |
| `analfabetismo` | numeric | Taxa de analfabetismo (15+ anos) | % |
| `uf` | character | Sigla do estado | - |
| `codigo_uf` | integer | Código numérico do estado | 2 dígitos |
| `codigo_munic` | character | Código do município (sem UF) | 5 dígitos |
| `nome_munic` | character | Nome do município (IBGE) | - |
| `populacao` | numeric | População total | milhares |
| `treatment` | numeric | Indicador de tratamento | 0 = Controle, 1 = Tratado |

**Códigos IPEA utilizados**:
- ADH_IDHM: IDHM
- ADH_PIND: % extrema pobreza
- ADH_RDPC: Renda per capita
- ADH_PMPOB: Proporção de pobres
- ADH_PREN10RICOS: Top 10% renda
- ADH_T_FREQ15A17: Frequência escolar
- ADH_T_ANALF15M: Analfabetismo

---

### 3. simec_2017_08.Rdata

**Descrição**: Snapshot do SIMEC em agosto 2017 (baseline, antes do projeto).

**Fonte**: SIMEC/FNDE (Sistema Integrado de Monitoramento, Execução e Controle do Fundo Nacional de Desenvolvimento da Educação)

**Dimensões**: 14,780 linhas × 15 colunas

**Unidade de observação**: Obra

**Objeto R**: `obras_inicio_projeto`

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `id` | character | Identificador único da obra |
| `nome` | character | Nome/descrição da obra |
| `situacao` | character | Status da obra (Ex: "Concluída", "Em Execução") |
| `municipio` | character | Nome do município |
| `uf` | character | Sigla do estado |
| `cep` | character | CEP da obra |
| `logradouro` | character | Endereço |
| `bairro` | character | Bairro |
| `percentual_de_execucao` | numeric | % de execução física | 0-100 |
| `data_prevista_de_conclusao_da_obra` | character | Data prevista de conclusão |
| `tipo_do_projeto` | character | Tipo do projeto (creche, escola, etc.) |
| `rede_de_ensino_publico` | character | Rede de ensino |
| `nome_da_entidade` | character | Entidade responsável |
| `visivel_no_app` | logical | Visível no app Tá de Pé |
| `grupo_controle` | logical | Grupo controle do app |

**Valores de `situacao`**:
- "Concluída"
- "Em Execução"
- "Paralisada"
- "Cancelada"
- "Inacabada"
- Outros

---

### 4. simec_2019_08.Rdata

**Descrição**: Snapshot do SIMEC em agosto 2019 (endline, após o projeto).

**Fonte**: SIMEC/FNDE

**Dimensões**: 15,092 linhas × 17 colunas

**Unidade de observação**: Obra

**Objeto R**: `obras_fim_seg_fase`

Mesmas variáveis de `simec_2017_08.Rdata`, com adições:

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `visivel_no_app_seg_fase` | logical | Visível no app (2ª fase) |
| `grupo_controle_app` | logical | Grupo controle app |
| `campanha_tdp` | logical | Campanha Tá de Pé |
| `grupo_controle_campanha` | logical | Grupo controle campanha |

---

### 5. treated_municipalities.csv

**Descrição**: Lista centralizada dos 21 municípios participantes do projeto Obra Transparente.

**Fonte**: Transparência Brasil

**Dimensões**: 21 linhas × 6 colunas

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `municipio` | character | Nome do município |
| `uf` | character | Sigla do estado |
| `treated` | numeric | Indicador de tratamento (sempre 1) |
| `project_name` | character | Nome do projeto ("Obra Transparente") |
| `start_date` | character | Data de início do projeto (2017-05-01) |
| `end_date` | character | Data de término do projeto (2019-06-30) |

**Lista completa dos municípios**:

| # | Município | UF |
|---|-----------|-----|
| 1 | Uberlândia | MG |
| 2 | Araucária | PR |
| 3 | Campo Mourão | PR |
| 4 | Cascavel | PR |
| 5 | Foz do Iguaçu | PR |
| 6 | Goioerê | PR |
| 7 | Guarapuava | PR |
| 8 | Paranaguá | PR |
| 9 | Ponta Grossa | PR |
| 10 | Gravataí | RS |
| 11 | Lajeado | RS |
| 12 | Pelotas | RS |
| 13 | Santa Maria | RS |
| 14 | Caçador | SC |
| 15 | Chapecó | SC |
| 16 | Imbituba | SC |
| 17 | Palhoça | SC |
| 18 | São Francisco do Sul | SC |
| 19 | Limeira | SP |
| 20 | São José dos Campos | SP |
| 21 | Taubaté | SP |

---

## Notas sobre Processamento

### Dados Pré-processados

Os arquivos `did_panel.rds`, `simec_2017_08.Rdata` e `simec_2019_08.Rdata` foram processados pela equipe da Transparência Brasil antes deste pacote de replicação. O código original de processamento não está disponível.

**Implicações**:
- A análise a partir desses dados é reproduzível
- A geração dos dados a partir do SIMEC bruto não é reproduzível sem acesso aos scripts originais da TB

### Variável de Conclusão

A variável `concluida` é derivada da variável `situacao`:
```r
concluida <- grepl("Concluída", situacao)
```

### Merge de Datasets

Para análise DiD, o dataset principal `did_panel.rds` deve ser merged com:
1. `municipal_covariates.rds` para covariáveis
2. `treated_municipalities.csv` para verificar tratamento

---

## Contato

Para questões sobre os dados:
- **Projeto**: Manoel Galdino (mgaldino@usp.br)
- **Transparência Brasil**: https://www.transparencia.org.br/

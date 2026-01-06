# Codebook - Obra Transparente DiD Analysis

**Data**: 2026-01-05
**Projeto**: Replication package for "The Civil Society Organizations effect" (Galdino et al., 2024)

---

## Visão Geral dos Dados

Este pacote de replicação contém dados para análise de diferenças-em-diferenças (DiD) do impacto do projeto Obra Transparente na conclusão de obras públicas de escolas e creches no Brasil.

### Fontes de Dados (Reproduzíveis)

| Fonte | Descrição | Acesso |
|-------|-----------|--------|
| SIMEC/FNDE | Sistema Integrado de Monitoramento | Snapshots via GitHub TB |
| Transparência Brasil | Lista de obras tratadas | `situacao obras_atual.xlsx` |
| GitHub TB | Repositórios públicos | Download automático |

### Repositórios GitHub (Transparência Brasil)

| Repositório | URL | Conteúdo |
|-------------|-----|----------|
| avaliacao_impacto_092019 | https://github.com/Transparencia-Brasil/avaliacao_impacto_092019 | Snapshots SIMEC (2017-2019) |
| campanha_TDP_2018 | https://github.com/Transparencia-Brasil/campanha_TDP_2018 | Dados campanha TDP |

### Período de Análise

- **Período 1**: Maio 2017 (baseline)
- **Período 2**: Março 2018
- **Período 3**: Setembro 2018 (início do tratamento)
- **Período 4**: Agosto 2019
- **Período 5**: Outubro 2023 (follow-up longo prazo)

### Cobertura Geográfica

Estados incluídos: SP, MG, SC, PR, RS (Sul e Sudeste)

---

## Arquivos de Dados

### 1. did_panel_5periods.rds (PRINCIPAL)

**Descrição**: Painel balanceado para análise DiD com 5 períodos.

**Criado por**: `code/01_did_analysis_5periods.R`

**Fontes originais**:
- `obras_inicio_projeto.Rdata` (período 1)
- `obras_08032018.csv` (período 2)
- `obras_upload28092018.csv` (período 3)
- `obras_fim_seg_fase.Rdata` (período 4)
- `simec 25-10-23 - simec.csv` (período 5)
- `situacao obras_atual.xlsx` (lista de tratados)

**Dimensões**: 22.616 linhas × 9 colunas

**Unidade de observação**: Obra × Período

| Variável | Tipo | Descrição | Valores |
|----------|------|-----------|---------|
| `id` | numeric | ID único da obra no SIMEC | Ex: 1366 |
| `municipio` | character | Nome do município | Ex: "Conchas" |
| `uf` | character | Sigla do estado | SP, MG, SC, PR, RS |
| `concluida` | numeric | Obra concluída neste período | 0 = Não, 1 = Sim |
| `group_treated` | numeric | Município no grupo tratado | 0 = Controle, 1 = Tratado |
| `periodo` | numeric | Período do painel | 1, 2, 3, 4, 5 |
| `post` | numeric | Período pós-tratamento (>=3) | 0 ou 1 |
| `treat_post` | numeric | Interação tratamento × pós | 0 ou 1 |
| `rel_time` | numeric | Tempo relativo ao tratamento | -2, -1, 0, +1, +2 |

**Como `concluida` é calculada**:
```r
concluida <- as.numeric(grepl("Concluída", situacao))
```

**Como `group_treated` é calculada**:
```r
# Baseado em se o município tem pelo menos uma obra na lista de tratados
group_treated <- max(indicator_ot) # por município
```

---

### 2. did_results_5periods.rds

**Descrição**: Resultados completos da análise DiD.

**Conteúdo** (lista R):
- `panel`: Dataset completo
- `stats`: Estatísticas descritivas
- `model_twfe`: Modelo TWFE (DiD estático)
- `model_es`: Modelo Event Study
- `es_coefs`: Coeficientes do event study

---

### 3. Arquivos Fonte (original/data/)

#### obras_inicio_projeto.Rdata

**Descrição**: Snapshot SIMEC maio 2017 (baseline).

**Objeto R**: `obras_inicio_projeto`

**Dimensões**: 14.780 obras × 15 colunas

**Nota**: Já filtrado para tipo "Construção" (exclui reformas, ampliações).

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `id` | integer | ID único da obra |
| `nome` | character | Nome/descrição da obra |
| `situacao` | character | Status (Concluída, Execução, Paralisada, etc.) |
| `municipio` | character | Nome do município |
| `uf` | character | Sigla do estado |
| `percentual_de_execucao` | numeric | % de execução física |
| `tipo_do_projeto` | character | Tipo do projeto (creche, escola) |

#### obras_fim_seg_fase.Rdata

**Descrição**: Snapshot SIMEC agosto 2019.

**Objeto R**: `obras_fim_seg_fase`

**Dimensões**: 15.092 obras × 17 colunas

Mesma estrutura de `obras_inicio_projeto.Rdata`.

#### situacao obras_atual.xlsx

**Descrição**: Lista de obras monitoradas pelo projeto Obra Transparente.

**Sheet utilizada**: "SIMEC-Mai17"

**Dimensões**: 136 obras em 21 municípios

---

## Municípios Tratados (21)

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

## Estatísticas Descritivas

### Tamanho da Amostra

| Grupo | Obras | Municípios |
|-------|-------|------------|
| Controle | 4.438 | 2.029 |
| Tratados | 226 | 21 |
| **Total** | **4.664** | **2.050** |

### Taxas de Conclusão por Período

| Período | Data | Controle | Tratados | Gap |
|---------|------|:--------:|:--------:|:---:|
| 1 | Mai/2017 | 49.4% | 28.8% | -20.6 pp |
| 2 | Mar/2018 | 54.4% | 32.7% | -21.7 pp |
| 3 | Set/2018 | 57.4% | 36.9% | -20.5 pp |
| 4 | Ago/2019 | 60.0% | 42.2% | -17.8 pp |
| 5 | Out/2023 | 86.5% | 80.4% | -6.1 pp |

---

## Notas sobre Reprodutibilidade

### Pipeline Reproduzível

Todo o painel é criado a partir de fontes rastreáveis:
1. Arquivos `.Rdata` da Transparência Brasil
2. CSVs baixados automaticamente do GitHub
3. Lista de tratados em Excel

### Variável `concluida`

A variável é calculada usando `grepl("Concluída", situacao)` aplicada ao campo `situacao` de cada snapshot SIMEC.

### Painel Balanceado

O painel usa apenas obras presentes no período 1 (maio 2017) para garantir balanceamento. Obras que aparecem apenas em períodos posteriores são excluídas.

---

## Contato

- **Autor**: Manoel Galdino (mgaldino@usp.br)
- **Transparência Brasil**: https://www.transparencia.org.br/

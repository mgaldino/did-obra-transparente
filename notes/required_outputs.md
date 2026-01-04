# Outputs Necessários para Replicação

**Data**: 2026-01-04
**Fonte**: Análise do paper.Rmd e scripts originais

---

## Resumo dos Outputs

O paper contém os seguintes outputs quantitativos que precisam ser reproduzidos:

| Output | Descrição | Script Original | Prioridade |
|--------|-----------|-----------------|------------|
| Table 1 | Summary Statistics municipais | table1.R | Alta |
| Table 2 | Completion rates antes/depois | paper.Rmd (inline) | Alta |
| Table 3 | Resultados Bayesian Matching | paper.Rmd (inline) | Média |
| DiD Estático | ATT two-way fixed effects | did.R | Alta |
| Event Study | Efeitos dinâmicos (Sun & Abraham) | did.R | Alta |
| Figure 1 | Event study plot | did.R (iplot) | Alta |

---

## Detalhamento dos Outputs

### Table 1: Summary Statistics Municipais

**Localização no paper**: Mencionada no texto como "descriptive statistics for these construction projects"

**Variáveis incluídas**:
- IDHM (Índice de Desenvolvimento Humano Municipal)
- % abaixo da linha de pobreza
- Renda per capita (R$ milhares)
- Taxa de pobreza (%)
- Participação dos 10% mais ricos (%)
- Taxa de frequência escolar (15-17 anos) (%)
- Taxa de analfabetismo (%)
- População (milhões)

**Formato**: Estatísticas (Mean, SD, Min, Max) por grupo (Controle vs Tratamento)

**Script**: `table1.R` gera `tables_figures/tab_01.rds`

---

### Table 2: Construction Completion Rates

**Localização no paper**: Chunk `table1` (linhas ~299-320 no paper.Rmd)

**Conteúdo**:
| Grupo | Ago 2017 (Antes) | Ago 2019 (Depois) |
|-------|------------------|-------------------|
| Não-participantes (Controle) | 49% | 59% |
| Participantes (Tratamento) | 29% | 42% |

**Nota**: Esta tabela mostra que o grupo tratado começou com taxa de conclusão MENOR mas teve maior crescimento.

**Script**: `table2.R` gera `tables_figures/table2.rds`

---

### Table 3: Bayesian Matching Results

**Localização no paper**: Chunk `table2` (linhas ~504-527 no paper.Rmd)

**Conteúdo**:
| Período | Posterior Mean | SD | Median | 2.5% CI | 97.5% CI |
|---------|----------------|-----|--------|---------|----------|
| ATT before project | ~0 | - | ~0 | - | - |
| ATT after project | ~0.10 | - | - | - | - |

**Interpretação**:
- Antes do projeto: efeito nulo (como esperado)
- Depois do projeto: aumento de ~10 p.p. na taxa de entrega

**Script**: Código inline em `paper.Rmd` (chunks `pscore`, `fitting bayesian model`, `processing bayes fit`)

---

### DiD Estático (Two-Way Fixed Effects)

**Localização**: `did.R`

**Modelo**:
```r
feols(concluida ~ post_treat | municipality + period,
      cluster = "municipality",
      data = data_ot1)
```

**Output esperado**:
- Coeficiente ATT (Treatment × Post)
- Erro padrão clusterizado
- N observações

**Arquivo**: `tables_figures/did_static.rds`

---

### Event Study (Sun & Abraham Estimator)

**Localização**: `did.R`

**Modelo**:
```r
feols(
  concluida ~ sunab(cohort = time_treated1, period = period, ref.p = 0)
  | municipality + period,
  cluster = ~ municipality,
  data = data_ot1
)
```

**Output esperado**:
- Coeficientes por período relativo (-2, -1, 0, +1, +2)
- Erros padrão
- Teste de tendências paralelas (coeficientes pré-tratamento ~0)

**Valores de referência do CLAUDE.md**:

| Período Relativo | Coeficiente | SE |
|------------------|-------------|-----|
| -2 | -0.01 | (0.05) |
| -1 | 0.00 | (0.02) |
| +1 | 0.02 | (0.02) |
| +2 | 0.14* | (0.07) |

**Arquivo**: `tables_figures/did_event_study.rds`

---

### Figure 1: Event Study Plot

**Tipo**: Gráfico de coeficientes com intervalos de confiança

**Geração**: `iplot(did_event_study)` no fixest

**Elementos**:
- Eixo X: Períodos relativos ao tratamento
- Eixo Y: Efeito estimado
- Barras de erro: Intervalo de confiança 95%
- Linha horizontal em y=0
- Linha vertical no período de referência (0)

---

## Dados Necessários para Reprodução

### Dados Primários (essenciais)
1. `obra_transparente.RDS` - Dataset principal DiD
2. `data_ot_desc.rds` - Covariáveis municipais
3. `obras_inicio_projeto.Rdata` - Baseline (ago/2017)
4. `obras_fim_seg_fase.Rdata` - Endline (ago/2019)
5. `situacao obras_atual.xlsx` - Lista de municípios tratados

### Dados Derivados (criados durante análise)
- `df_balancing_aux_se.RData` - Dados para matching (pré)
- `df_balancing_aux_post_se.RData` - Dados para matching (pós)

---

## Priorização da Replicação

### Fase 1: Core DiD (ALTA PRIORIDADE)
1. Table 2 (completion rates)
2. DiD Estático
3. Event Study + Figure 1

### Fase 2: Descritivas (ALTA PRIORIDADE)
4. Table 1 (summary statistics)

### Fase 3: Análise Bayesiana (MÉDIA PRIORIDADE)
5. Table 3 (Bayesian matching results)

**Nota**: A análise bayesiana é mais complexa e pode ser deixada para depois se o tempo for limitado. O core da contribuição empírica está no DiD e event study.

---

## Checklist de Validação

Após reproduzir cada output, verificar:

- [ ] Table 1: N de municípios tratados = 21
- [ ] Table 2: Completion rate tratados ago/2017 = 29%
- [ ] Table 2: Completion rate tratados ago/2019 = 42%
- [ ] Table 2: Completion rate controle ago/2017 = 49%
- [ ] Table 2: Completion rate controle ago/2019 = 59%
- [ ] Event Study: Coeficientes pré-tratamento ~0 (tendências paralelas)
- [ ] Event Study: Coeficiente período +2 = ~0.14
- [ ] DiD Estático: ATT positivo e significativo

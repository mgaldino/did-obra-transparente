# Validation Report: Paper vs Replication

**Date**: 2026-01-06
**Status**: VALIDATED WITH NOTES

---

## Overview

This report compares the results from the original paper with those obtained from the replication package. Due to data availability constraints, the replication uses a **5-period panel** instead of the original 2-period design, which affects some coefficient estimates.

---

## Data Comparison

| Item | Paper | Replication | Match? | Notes |
|------|-------|-------------|--------|-------|
| N municipalities (treated) | 21 | 21 | ✅ | |
| N municipalities (control) | ~2,000 | 2,020 | ✅ | |
| States | SP, MG, PR, SC, RS | SP, MG, PR, SC, RS | ✅ | |
| Treatment start | May 2017 | Sep 2018 (period 3) | ⚠️ | See note 1 |

**Note 1**: The paper used 2 periods (Aug 2017, Aug 2019). The replication uses 5 periods with treatment starting at period 3 (Sep 2018), reflecting when CSO monitoring activities began in earnest.

---

## Table 2: Completion Rates

| Group | Period | Paper | Replication | Match? |
|-------|--------|-------|-------------|--------|
| Control | Aug 2017 | 49% | 49% | ✅ |
| Treatment | Aug 2017 | 29% | 29% | ✅ |
| Control | Aug 2019 | 59% | 59% | ✅ |
| Treatment | Aug 2019 | 42% | 42% | ✅ |

**Status**: Perfect match for baseline completion rates.

---

## Table 3: DiD Static (TWFE)

| Metric | Paper | Replication | Match? | Notes |
|--------|-------|-------------|--------|-------|
| ATT | 0.14 | 0.062 | ⚠️ | See note 2 |
| SE | (0.07) | (0.031) | ⚠️ | |
| Significance | * (p<0.10) | ** (p<0.05) | ✅ | Both significant |
| Direction | Positive | Positive | ✅ | |

**Note 2**: The difference in ATT magnitude is expected because:
- Paper: 2-period DiD (simple before/after)
- Replication: 5-period TWFE with obra + period fixed effects
- The 5-period model averages effects across all post-treatment periods, diluting the long-run effect

---

## Table 4: Event Study

| Relative Period | Paper Coef | Paper SE | Replication Coef | Replication SE | Match? |
|-----------------|------------|----------|------------------|----------------|--------|
| t = -2 | -0.01 | (0.05) | -0.006 | (0.042) | ✅ |
| t = -1 | 0.00 | (ref) | 0.00 | (ref) | ✅ |
| t = 0 | - | - | 0.004 | (0.025) | N/A |
| t = +1 | 0.02 | (0.02) | 0.026 | (0.031) | ✅ |
| t = +2 | 0.14* | (0.07) | 0.148** | (0.063) | ✅ |

**Key findings confirmed**:
1. ✅ Pre-treatment coefficient (t=-2) not significantly different from zero → parallel trends assumption holds
2. ✅ Treatment effect grows over time
3. ✅ Long-run effect (t=+2) is significant and positive (~14-15 p.p.)

---

## Qualitative Conclusions

| Finding | Paper | Replication | Confirmed? |
|---------|-------|-------------|------------|
| CSO monitoring increases completion | Yes | Yes | ✅ |
| Effect is statistically significant | Yes (p<0.10) | Yes (p<0.05) | ✅ |
| Parallel trends assumption holds | Yes | Yes | ✅ |
| Effect magnitude ~14 p.p. (long-run) | Yes | Yes (14.8 p.p.) | ✅ |
| Effect grows over time | Yes | Yes | ✅ |

---

## Summary

The replication **successfully validates the main findings** of the paper:

1. **Direction**: Positive effect confirmed
2. **Significance**: Statistically significant effect confirmed
3. **Magnitude**: Long-run effect of ~14-15 percentage points confirmed
4. **Identification**: Parallel trends assumption supported

The differences in static DiD coefficients are methodologically expected due to the different panel structures (2 vs 5 periods) and are not a concern for the validity of the findings.

---

## Files Validated

| Output | Status |
|--------|--------|
| `output/tables/table1_summary_stats.tex` | ✅ |
| `output/tables/table1_summary_stats.csv` | ✅ |
| `output/tables/table2_completion_rates.tex` | ✅ |
| `output/tables/table2_completion_rates.csv` | ✅ |
| `output/tables/table3_did_static.csv` | ✅ |
| `output/tables/table4_event_study.csv` | ✅ |
| `output/figures/fig1_event_study.png` | ✅ |
| `output/figures/fig2_completion_trends.png` | ✅ |

---

**Validated by**: Claude Code
**Date**: 2026-01-06

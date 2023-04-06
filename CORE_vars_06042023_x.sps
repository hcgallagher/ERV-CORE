* Encoding: UTF-8.
*** This file takes the prepped file and adds a few variable transfomations.

GET
  FILE='DO_NOT_SHARE_DO_NOT_ALTER_BRV_2870_17Feb202_Data_START_varlabs_LGA.sav'.
DATASET NAME CORE2 WINDOW=FRONT.

***Kessler-6 scores
    
***Here, we use the scoring that is commonly found across sources.
*** See https://www.abs.gov.au/ausstats/abs@.nsf/lookup/4817.0.55.001chapter92007-08 for discussion of methods for K-10
***See [Andrews and Slade (2001)](https://onlinelibrary.wiley.com/doi/epdf/10.1111/j.1467-842X.2001.tb00310.x) for background research on sensitivity levels.

COMPUTE K6_sum =   Q7_A + 
Q7_B + 
Q7_D + 
Q7_H + 
Q7_I + 
Q7_J.

COMPUTE K10_sum =   Q7_A + 
Q7_B + 
Q7_C + 
Q7_D + 
Q7_E + 
Q7_F + 
Q7_G + 
Q7_H + 
Q7_I + 
Q7_J.

DO IF K6_sum = 6.
COMPUTE K6_levels = 0.
ELSE IF K6_sum >= 7 AND K6_sum <= 13.
COMPUTE K6_levels = 1.
ELSE IF K6_sum >= 14 AND K6_sum <= 18.
COMPUTE K6_levels = 2.
ELSE IF K6_sum >= 19 AND K6_sum <= 24.
COMPUTE K6_levels = 3.
ELSE IF K6_sum >= 25.
COMPUTE K6_levels = 4.
END IF.
EXECUTE.

COMPUTE K6_cutoff = K6_sum >= 19.
EXECUTE.

DO IF K10_sum <= 15.
COMPUTE K10_levels_scoring_1 = 0.
ELSE IF K10_sum >= 16 AND K10_sum <=21.
COMPUTE K10_levels_scoring_1 = 1.
ELSE IF K10_sum >= 22 AND K10_sum <=29.
COMPUTE K10_levels_scoring_1 = 2.
ELSE IF K10_sum >= 30.
COMPUTE K10_levels_scoring_1 = 3.
END IF.
EXECUTE.

DO IF K10_sum < 20.
COMPUTE K10_levels_scoring_2 = 0.
ELSE IF K10_sum >= 20 AND K10_sum < 25.
COMPUTE K10_levels_scoring_2 = 1.
ELSE IF K10_sum >= 25 AND K10_sum < 30.
COMPUTE K10_levels_scoring_2 = 2.
ELSE IF K10_sum >= 30.
COMPUTE K10_levels_scoring_2 = 3.
END IF.
EXECUTE.

VARIABLE LABELS
K6_sum 'Kessler-6 raw score (6-30)'
K10_sum 'Kessler-10 raw score (10-50)'
K6_cutoff 'Kessler-6 cutoff score (19 or greater)'
K6_levels 'Kessler-6 levels'
K10_levels_scoring_1 'Kessler-10 levels, Scoring method 1 (ABS)'
K10_levels_scoring_2 'Kessler-10 levels, Scoring method 2 (VPHS)'.

FORMATS
K6_cutoff K6_levels K10_levels_scoring_1 K10_levels_scoring_2 (F1).

VALUE LABELS
K6_cutoff 
0 'No probable serious mental illness'
1 'Probable serious mental illness'.

VALUE LABELS
K6_levels
0 'No distress'
1 'Little distress'
2 'Mild distress'
3 'Moderate mental disorder'
4 'Severe mental disorder'.

VALUE LABELS
K10_levels_scoring_1
0 'Low'
1 'Moderate'
2 'High'
3 'Very high'.

VALUE LABELS
K10_levels_scoring_2
0 'Likely to be well'
1 'Mild mental disorder'
2 'Moderate mental disorder'
3 'Severe mental disorder'.

VARIABLE LEVEL K6_cutoff K6_levels K10_levels_scoring_1 K10_levels_scoring_2 (ORDINAL).

FREQUENCIES VARIABLES=K6_cutoff K6_sum K6_levels K10_levels_scoring_1 K10_levels_scoring_2 
  /STATISTICS=STDDEV RANGE MEAN MEDIAN
  /HISTOGRAM
  /ORDER=ANALYSIS.
 
***Bushfire impact scores
    
COMPUTE BF5_LOSS = MAX(Q3_A_2, Q3_A_3, Q3_A_4).
COMPUTE BF5_DAMAGE = MAX(Q3_B_2, Q3_B_3, Q3_B_4).
COMPUTE BF5_RISK = MAX(Q3_C_2, Q3_C_3, Q3_C_4).
EXECUTE.

RECODE BF5_LOSS
BF5_DAMAGE
BF5_RISK (MISSING = 0).

DO IF Q1_1 = 1 AND BF5_LOSS = 1.
COMPUTE BUSHFIRE_5YEAR_LEVEL = 4.
ELSE IF Q1_1 = 1 AND BF5_DAMAGE= 1.
COMPUTE BUSHFIRE_5YEAR_LEVEL = 3.
ELSE IF Q1_1 = 1 AND BF5_RISK = 1.
COMPUTE BUSHFIRE_5YEAR_LEVEL = 2.
ELSE IF (Q1_1 =0 OR MISSING(Q1_1)= 1).
COMPUTE BUSHFIRE_5YEAR_LEVEL = 1.
END IF.
EXECUTE.

VARIABLE LABELS
BUSHFIRE_5YEAR_LEVEL 'Black summer housing impact (5-year window corrected)'.

FORMATS
BUSHFIRE_5YEAR_LEVEL (F1).

VALUE LABELS
BUSHFIRE_5YEAR_LEVEL
1 'Not at risk'
2 'Risk'
3 'Damage'
4 'Loss / uninhabitable'.

VARIABLE LEVEL BUSHFIRE_5YEAR_LEVEL (ORDINAL).

DELETE VARIABLES   BF5_LOSS
BF5_DAMAGE
BF5_RISK.

FREQUENCIES VARIABLES=BUSHFIRE_5YEAR_LEVEL
  /STATISTICS=STDDEV RANGE MEAN MEDIAN
  /HISTOGRAM
  /ORDER=ANALYSIS.

***
    
DATASET NAME CORE2 WINDOW=FRONT.
SAVE OUTFILE='SHARE__WITH_ERV_2870_6April2023.sav'
  /COMPRESSED.

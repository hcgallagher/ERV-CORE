* Encoding: UTF-8.
***This syntax preps the SRC data if needed.
***As of 6 April 2023, all we need to do is fix some 
***However, Location-wise, we only have localities and SA1, Not postcode.
    

*** The following code works on an internal file that has matched SA1s and LGAs. It will be merged in a following step.

PRESERVE.
SET DECIMAL DOT.

GET DATA  /TYPE=TXT
  /FILE="SA1_and_LGA_2.csv"
  /ENCODING='UTF8'
  /DELCASE=LINE
  /DELIMITERS=","
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /DATATYPEMIN PERCENTAGE=95.0
  /VARIABLES=
  SA1_CODE21 AUTO
  SA2_CODE21 AUTO
  SA2_NAME21 AUTO
  SA3_CODE21 AUTO
  SA3_NAME21 AUTO
  SA4_CODE21 AUTO
  SA4_NAME21 AUTO
  LGA_CODE22 AUTO
  LGA_NAME22 AUTO
  LGA_2022_AUST_GDA2020_area AUTO
  LGA_2022_AUST_GDA2020_pc AUTO
  STE_CODE21 AUTO
  STE_NAME21 AUTO
  exist AUTO
  /MAP.
RESTORE.

CACHE.
EXECUTE.
DATASET NAME SA1LGA WINDOW=FRONT.

RENAME VARIABLES (SA1_CODE21 = SA1_MAINCODE_2021).

SAVE OUTFILE='Z:\20. BRV Community Outcomes Survey\4. Data\4. Auxilliary data\1. ABS boundaries\SA1_and_LGA.sav'
  /COMPRESSED.

*** working on the mainfile

GET
  FILE='DO_NOT_SHARE_DO_NOT_ALTER_BRV_2870_17Feb202_Data_START.sav'.
DATASET NAME CORE WINDOW=FRONT.
    
*** Some housekeeping

VARIABLE LABELS
Q3_A_2 'Q3. Have you or your household ever experienced any of the following due to bushfire, natural hazards or other similar events? - Your / My home was destroyed / damaged to a point where it couldn’t be lived in - Yes – in 2021/ 2022'
Q3_A_3 'Q3. Have you or your household ever experienced any of the following due to bushfire, natural hazards or other similar events? - Your / My home was destroyed / damaged to a point where it couldn’t be lived in - Yes – in 2019 / 2020 (Black Sm)'
Q3_A_4 'Q3. Have you or your household ever experienced any of the following due to bushfire, natural hazards or other similar events? - Your / My home was destroyed / damaged to a point where it couldn’t be lived in - Yes – in 2017 or 2018'
Q3_A_5 'Q3. Have you or your household ever experienced any of the following due to bushfire, natural hazards or other similar events? - Your / My home was destroyed / damaged to a point where it couldn’t be lived in - Yes – between 2012 and 2016'
Q3_A_6 'Q3. Have you or your household ever experienced any of the following due to bushfire, natural hazards or other similar events? - Your / My home was destroyed / damaged to a point where it couldn’t be lived in - Yes – before 2012'
Q3_A_98 'Q3. Have you or your household ever experienced any of the following due to bushfire, natural hazards or other similar events? - Your / My home was destroyed / damaged to a point where it couldn’t be lived in - Not sure'
Q3_A_99 'Q3. Have you or your household ever experienced any of the following due to bushfire, natural hazards or other similar events? - Your / My home was destroyed / damaged to a point where it couldn’t be lived in - Prefer not to say'
Q3_A_100 'Q3. Have you or your household ever experienced any of the following due to bushfire, natural hazards or other similar events? - Your / My home was destroyed / damaged to a point where it couldn’t be lived in - skip'.


***
    
* Define Variable Properties.
*SA1_MAINCODE_2021.
ALTER TYPE  SA1_MAINCODE_2021 SA1_7DIGITCODE_2021 (F25.0).
*SA1_MAINCODE_2021.
FORMATS  SA1_MAINCODE_2021 SA1_7DIGITCODE_2021 (F25.0).
EXECUTE.


GET FILE='SA1_and_LGA.sav'.
DATASET NAME SA1_LGA.
DATASET ACTIVATE CORE.
SORT CASES BY SA1_MAINCODE_2021.
DATASET ACTIVATE SA1_LGA.
SORT CASES BY SA1_MAINCODE_2021.
DATASET ACTIVATE CORE.
MATCH FILES /FILE=*
  /TABLE='SA1_LGA'
  /RENAME (SA2_CODE21 SA2_NAME21 SA3_CODE21 SA3_NAME21 SA4_CODE21 SA4_NAME21 
    LGA_2022_AUST_GDA2020_area LGA_2022_AUST_GDA2020_pc STE_CODE21 STE_NAME21 exist = d0 d1 d2 d3 d4 d5 
    d6 d7 d8 d9 d10) 
  /BY SA1_MAINCODE_2021
  /DROP= d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10.
EXECUTE.

DO IF SAMPLESOURCE = 2.
COMPUTE LGA_NAME22 = "Unknown/Web".
END IF.
EXECUTE.

SAVE OUTFILE='DO_NOT_SHARE_DO_NOT_ALTER_BRV_2870_17Feb202_Data_START_varlabs_LGA.sav'
  /COMPRESSED.


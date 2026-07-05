* Encoding: UTF-8.

* ============================================================.
* OSSLT Success Rate Project
* ============================================================.

SET PRINTBACK=OFF MPRINT=OFF MXWARNS=0.

* Hide SPSS Notes tables from Output Viewer.
OMS
  /SELECT TABLES
  /IF SUBTYPES=['Notes']
  /DESTINATION VIEWER=NO
  /TAG='NoNotes_FinalRun'.

* Hide unnecessary regression housekeeping tables.
OMS
  /SELECT TABLES
  /IF COMMANDS=['Regression']
      SUBTYPES=['Variables Entered/Removed' 'Residuals Statistics']
  /DESTINATION VIEWER=NO
  /TAG='HideRegressionJunk_FinalRun'.


* ============================================================.
* Block 1: Load raw imported SPSS file and clean variables.
* ============================================================.

GET FILE='D:\302_OSSLT_DASH\OSSLT_raw_imported.sav'.
DATASET NAME OSSLT_RAW WINDOW=FRONT.

MATCH FILES FILE=*
  /KEEP=
    OSSLT_Raw
    School_Type
    School_Language
    Special_Ed_Raw
    Low_Income_Raw
    No_Parent_Degree_Raw.
EXECUTE.


* ============================================================.
* Clean categorical variables.
* ============================================================.

STRING School_Type_Clean (A30).
STRING School_Language_Clean (A30).

COMPUTE School_Type_Clean = RTRIM(LTRIM(School_Type)).
COMPUTE School_Language_Clean = RTRIM(LTRIM(School_Language)).
EXECUTE.


* ============================================================.
* Convert raw numeric/string variables into real numeric variables.
* Raw file contains nonnumeric strings such as SP and N/D.
* These are blanked before NUMBER().
* ============================================================.

STRING OSSLT_Str Special_Ed_Str Low_Income_Str No_Parent_Degree_Str (A40).

COMPUTE OSSLT_Str = RTRIM(LTRIM(OSSLT_Raw)).
COMPUTE Special_Ed_Str = RTRIM(LTRIM(Special_Ed_Raw)).
COMPUTE Low_Income_Str = RTRIM(LTRIM(Low_Income_Raw)).
COMPUTE No_Parent_Degree_Str = RTRIM(LTRIM(No_Parent_Degree_Raw)).
EXECUTE.

IF (UPCASE(OSSLT_Str) = "NA" OR UPCASE(OSSLT_Str) = "N/A" OR
    UPCASE(OSSLT_Str) = "N/R" OR UPCASE(OSSLT_Str) = "N/D" OR
    UPCASE(OSSLT_Str) = "ND" OR UPCASE(OSSLT_Str) = "SP" OR
    UPCASE(OSSLT_Str) = "SUPPRESSED" OR OSSLT_Str = "" OR OSSLT_Str = ".") OSSLT_Str = "".

IF (UPCASE(Special_Ed_Str) = "NA" OR UPCASE(Special_Ed_Str) = "N/A" OR
    UPCASE(Special_Ed_Str) = "N/R" OR UPCASE(Special_Ed_Str) = "N/D" OR
    UPCASE(Special_Ed_Str) = "ND" OR UPCASE(Special_Ed_Str) = "SP" OR
    UPCASE(Special_Ed_Str) = "SUPPRESSED" OR Special_Ed_Str = "" OR Special_Ed_Str = ".") Special_Ed_Str = "".

IF (UPCASE(Low_Income_Str) = "NA" OR UPCASE(Low_Income_Str) = "N/A" OR
    UPCASE(Low_Income_Str) = "N/R" OR UPCASE(Low_Income_Str) = "N/D" OR
    UPCASE(Low_Income_Str) = "ND" OR UPCASE(Low_Income_Str) = "SP" OR
    UPCASE(Low_Income_Str) = "SUPPRESSED" OR Low_Income_Str = "" OR Low_Income_Str = ".") Low_Income_Str = "".

IF (UPCASE(No_Parent_Degree_Str) = "NA" OR UPCASE(No_Parent_Degree_Str) = "N/A" OR
    UPCASE(No_Parent_Degree_Str) = "N/R" OR UPCASE(No_Parent_Degree_Str) = "N/D" OR
    UPCASE(No_Parent_Degree_Str) = "ND" OR UPCASE(No_Parent_Degree_Str) = "SP" OR
    UPCASE(No_Parent_Degree_Str) = "SUPPRESSED" OR No_Parent_Degree_Str = "" OR No_Parent_Degree_Str = ".") No_Parent_Degree_Str = "".
EXECUTE.

COMPUTE OSSLT_Str =
  REPLACE(REPLACE(REPLACE(OSSLT_Str, "%", ""), ",", ""), " ", "").
COMPUTE Special_Ed_Str =
  REPLACE(REPLACE(REPLACE(Special_Ed_Str, "%", ""), ",", ""), " ", "").
COMPUTE Low_Income_Str =
  REPLACE(REPLACE(REPLACE(Low_Income_Str, "%", ""), ",", ""), " ", "").
COMPUTE No_Parent_Degree_Str =
  REPLACE(REPLACE(REPLACE(No_Parent_Degree_Str, "%", ""), ",", ""), " ", "").
EXECUTE.

IF (UPCASE(OSSLT_Str) = "NA" OR UPCASE(OSSLT_Str) = "N/A" OR
    UPCASE(OSSLT_Str) = "NR" OR UPCASE(OSSLT_Str) = "ND" OR
    UPCASE(OSSLT_Str) = "SP" OR OSSLT_Str = "" OR OSSLT_Str = ".") OSSLT_Str = "".

IF (UPCASE(Special_Ed_Str) = "NA" OR UPCASE(Special_Ed_Str) = "N/A" OR
    UPCASE(Special_Ed_Str) = "NR" OR UPCASE(Special_Ed_Str) = "ND" OR
    UPCASE(Special_Ed_Str) = "SP" OR Special_Ed_Str = "" OR Special_Ed_Str = ".") Special_Ed_Str = "".

IF (UPCASE(Low_Income_Str) = "NA" OR UPCASE(Low_Income_Str) = "N/A" OR
    UPCASE(Low_Income_Str) = "NR" OR UPCASE(Low_Income_Str) = "ND" OR
    UPCASE(Low_Income_Str) = "SP" OR Low_Income_Str = "" OR Low_Income_Str = ".") Low_Income_Str = "".

IF (UPCASE(No_Parent_Degree_Str) = "NA" OR UPCASE(No_Parent_Degree_Str) = "N/A" OR
    UPCASE(No_Parent_Degree_Str) = "NR" OR UPCASE(No_Parent_Degree_Str) = "ND" OR
    UPCASE(No_Parent_Degree_Str) = "SP" OR No_Parent_Degree_Str = "" OR No_Parent_Degree_Str = ".") No_Parent_Degree_Str = "".
EXECUTE.

DO IF (OSSLT_Str <> "").
  COMPUTE OSSLT_First_Attempt_PassRate = NUMBER(OSSLT_Str, F8.2).
END IF.

DO IF (Special_Ed_Str <> "").
  COMPUTE Special_Ed_Pct = NUMBER(Special_Ed_Str, F8.2).
END IF.

DO IF (Low_Income_Str <> "").
  COMPUTE Low_Income_Pct = NUMBER(Low_Income_Str, F8.2).
END IF.

DO IF (No_Parent_Degree_Str <> "").
  COMPUTE No_Parent_Degree_Pct = NUMBER(No_Parent_Degree_Str, F8.2).
END IF.

EXECUTE.


* ============================================================.
* Convert imported proportion-scale fields to percentage scale if needed.
* ============================================================.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=
  /Max_OSSLT = MAX(OSSLT_First_Attempt_PassRate)
  /Max_Special_Ed = MAX(Special_Ed_Pct)
  /Max_Low_Income = MAX(Low_Income_Pct)
  /Max_No_Parent_Degree = MAX(No_Parent_Degree_Pct).

DO IF (Max_OSSLT <= 1.5).
  COMPUTE OSSLT_First_Attempt_PassRate = OSSLT_First_Attempt_PassRate * 100.
END IF.

DO IF (Max_Special_Ed <= 1.5).
  COMPUTE Special_Ed_Pct = Special_Ed_Pct * 100.
END IF.

DO IF (Max_Low_Income <= 1.5).
  COMPUTE Low_Income_Pct = Low_Income_Pct * 100.
END IF.

DO IF (Max_No_Parent_Degree <= 1.5).
  COMPUTE No_Parent_Degree_Pct = No_Parent_Degree_Pct * 100.
END IF.

EXECUTE.

MATCH FILES FILE=*
  /DROP=
    Max_OSSLT
    Max_Special_Ed
    Max_Low_Income
    Max_No_Parent_Degree
    OSSLT_Str
    Special_Ed_Str
    Low_Income_Str
    No_Parent_Degree_Str.
EXECUTE.


* ============================================================.
* Keep complete numeric cases only.
* ============================================================.

SELECT IF (
  NOT MISSING(OSSLT_First_Attempt_PassRate) AND
  NOT MISSING(Special_Ed_Pct) AND
  NOT MISSING(Low_Income_Pct) AND
  NOT MISSING(No_Parent_Degree_Pct)
).
EXECUTE.

COMPUTE Clean_Case_ID = $CASENUM.
EXECUTE.


* ============================================================.
* Keep final cleaned variables only.
* ============================================================.

MATCH FILES FILE=*
  /KEEP=
    Clean_Case_ID
    OSSLT_First_Attempt_PassRate
    School_Type_Clean
    School_Language_Clean
    Special_Ed_Pct
    Low_Income_Pct
    No_Parent_Degree_Pct.
EXECUTE.

RENAME VARIABLES
  (School_Type_Clean = School_Type)
  (School_Language_Clean = School_Language).
EXECUTE.


* ============================================================.
* Compact output labels.
* This is important: shorter labels reduce SPSS table width
* and help prevent page breaks / split coefficient tables.
* ============================================================.

VARIABLE LABELS
  Clean_Case_ID "Case ID"
  OSSLT_First_Attempt_PassRate "OSSLT Pass Rate"
  School_Type "School Type"
  School_Language "School Language"
  Special_Ed_Pct "Special Ed %"
  Low_Income_Pct "Low Income %"
  No_Parent_Degree_Pct "No Parent Degree %".

FORMATS
  Clean_Case_ID (F8.0)
  OSSLT_First_Attempt_PassRate
  Special_Ed_Pct
  Low_Income_Pct
  No_Parent_Degree_Pct (F8.2).


* ============================================================.
* Dummy coding.
* ============================================================.

COMPUTE School_Type_Public = (RTRIM(LTRIM(School_Type)) = "Public").
COMPUTE School_Language_French = (RTRIM(LTRIM(School_Language)) = "French").
EXECUTE.

VARIABLE LABELS
  School_Type_Public "Public School"
  School_Language_French "French School".

VALUE LABELS School_Type_Public
  0 "Catholic"
  1 "Public".

VALUE LABELS School_Language_French
  0 "English"
  1 "French".

FORMATS School_Type_Public School_Language_French (F1.0).

SAVE OUTFILE='D:\302_OSSLT_DASH\OSSLT_cleaned_for_SPSS.sav'
  /COMPRESSED.
EXECUTE.


* ============================================================.
* Block 2: Cleaning verification.
* ============================================================.

DESCRIPTIVES VARIABLES=
  OSSLT_First_Attempt_PassRate
  Special_Ed_Pct
  Low_Income_Pct
  No_Parent_Degree_Pct
  /STATISTICS=MEAN STDDEV MIN MAX.

FREQUENCIES VARIABLES=School_Type School_Language.


* ============================================================.
* Block 3: Descriptive plots and preliminary regression.
* ============================================================.

GRAPH
  /BAR(SIMPLE)=COUNT BY School_Type.

GRAPH
  /BAR(SIMPLE)=COUNT BY School_Language.

GRAPH
  /HISTOGRAM(NORMAL)=Special_Ed_Pct.

GRAPH
  /HISTOGRAM(NORMAL)=Low_Income_Pct.

GRAPH
  /HISTOGRAM(NORMAL)=No_Parent_Degree_Pct.

OMS
  /SELECT TEXTS
  /DESTINATION VIEWER=NO
  /TAG='HideRegTexts_Prelim_FinalRun'.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT OSSLT_First_Attempt_PassRate
  /METHOD=ENTER School_Type_Public School_Language_French
                Special_Ed_Pct Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_Prelim) RESID(Res_Prelim) ZRESID(ZRes_Prelim).

OMSEND TAG='HideRegTexts_Prelim_FinalRun'.

GRAPH
  /SCATTERPLOT(BIVAR)=Pred_Prelim WITH Res_Prelim
  /TITLE='Preliminary Model: Residuals vs Fitted'.


* ============================================================.
* Block 4: Response transformations.
* Hide original/log/square regression tables but still save residuals.
* Keep square-root model visible.
* ============================================================.

COMPUTE OSSLT_Response = OSSLT_First_Attempt_PassRate + 0.001.
COMPUTE OSSLT_Log = LN(OSSLT_Response + 0.001).
COMPUTE OSSLT_Sqrt = SQRT(OSSLT_Response).
COMPUTE OSSLT_Square = OSSLT_Response ** 2.
EXECUTE.

OMS
  /SELECT ALL
  /DESTINATION VIEWER=NO
  /TAG='HideYModels_FinalRun'.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /DEPENDENT OSSLT_Response
  /METHOD=ENTER School_Type_Public School_Language_French
                Special_Ed_Pct Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_Original) RESID(Res_Original).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /DEPENDENT OSSLT_Log
  /METHOD=ENTER School_Type_Public School_Language_French
                Special_Ed_Pct Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_Log) RESID(Res_Log).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /DEPENDENT OSSLT_Square
  /METHOD=ENTER School_Type_Public School_Language_French
                Special_Ed_Pct Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_Square) RESID(Res_Square).

OMSEND TAG='HideYModels_FinalRun'.

OMS
  /SELECT TEXTS
  /DESTINATION VIEWER=NO
  /TAG='HideRegTexts_Sqrt_FinalRun'.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /DEPENDENT OSSLT_Sqrt
  /METHOD=ENTER School_Type_Public School_Language_French
                Special_Ed_Pct Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_Sqrt) RESID(Res_Sqrt).

OMSEND TAG='HideRegTexts_Sqrt_FinalRun'.


* ============================================================.
* Block 5: Manual RSS, AIC, and BIC for response transformation models.
* ============================================================.

COMPUTE RSS_Original_i = Res_Original ** 2.
COMPUTE RSS_Log_i = Res_Log ** 2.
COMPUTE RSS_Sqrt_i = Res_Sqrt ** 2.
COMPUTE RSS_Square_i = Res_Square ** 2.
EXECUTE.

DATASET DECLARE YTransform_Metrics.

AGGREGATE
  /OUTFILE='YTransform_Metrics'
  /BREAK=
  /N_Original=N(RSS_Original_i)
  /RSS_Original=SUM(RSS_Original_i)
  /N_Log=N(RSS_Log_i)
  /RSS_Log=SUM(RSS_Log_i)
  /N_Sqrt=N(RSS_Sqrt_i)
  /RSS_Sqrt=SUM(RSS_Sqrt_i)
  /N_Square=N(RSS_Square_i)
  /RSS_Square=SUM(RSS_Square_i).

DATASET ACTIVATE YTransform_Metrics.

COMPUTE K_Original = 7.
COMPUTE K_Log = 7.
COMPUTE K_Sqrt = 7.
COMPUTE K_Square = 7.

COMPUTE AIC_Original =
  N_Original*(LN(2*3.141592653589793)+1+LN(RSS_Original/N_Original)) + 2*K_Original.
COMPUTE BIC_Original =
  N_Original*(LN(2*3.141592653589793)+1+LN(RSS_Original/N_Original)) + LN(N_Original)*K_Original.

COMPUTE AIC_Log =
  N_Log*(LN(2*3.141592653589793)+1+LN(RSS_Log/N_Log)) + 2*K_Log.
COMPUTE BIC_Log =
  N_Log*(LN(2*3.141592653589793)+1+LN(RSS_Log/N_Log)) + LN(N_Log)*K_Log.

COMPUTE AIC_Sqrt =
  N_Sqrt*(LN(2*3.141592653589793)+1+LN(RSS_Sqrt/N_Sqrt)) + 2*K_Sqrt.
COMPUTE BIC_Sqrt =
  N_Sqrt*(LN(2*3.141592653589793)+1+LN(RSS_Sqrt/N_Sqrt)) + LN(N_Sqrt)*K_Sqrt.

COMPUTE AIC_Square =
  N_Square*(LN(2*3.141592653589793)+1+LN(RSS_Square/N_Square)) + 2*K_Square.
COMPUTE BIC_Square =
  N_Square*(LN(2*3.141592653589793)+1+LN(RSS_Square/N_Square)) + LN(N_Square)*K_Square.
EXECUTE.

OMS
  /SELECT ALL
  /DESTINATION VIEWER=NO
  /TAG='HideVarstocases_Y_FinalRun'.

VARSTOCASES
  /MAKE N FROM N_Original N_Log N_Sqrt N_Square
  /MAKE RSS FROM RSS_Original RSS_Log RSS_Sqrt RSS_Square
  /MAKE AIC FROM AIC_Original AIC_Log AIC_Sqrt AIC_Square
  /MAKE BIC FROM BIC_Original BIC_Log BIC_Sqrt BIC_Square
  /INDEX=Transformation_Model(4)
  /NULL=KEEP.

OMSEND TAG='HideVarstocases_Y_FinalRun'.

VALUE LABELS Transformation_Model
  1 "Original"
  2 "Log"
  3 "Square root"
  4 "Square".

VARIABLE LABELS
  Transformation_Model "Response transformation model"
  N "N"
  RSS "RSS"
  AIC "AIC"
  BIC "BIC".

FORMATS N (F5.0) RSS AIC BIC (F12.4).

LIST VARIABLES=Transformation_Model N RSS AIC BIC.

DATASET ACTIVATE OSSLT_RAW.
DATASET CLOSE YTransform_Metrics.


* ============================================================.
* Block 6: Predictor transformation and model selection.
* Keep Model C visible; hide A, B, and D full regression tables.
* ============================================================.

COMPUTE Special_Ed_Sq = Special_Ed_Pct ** 2.
VARIABLE LABELS Special_Ed_Sq "Special Ed % Squared".
EXECUTE.

OMS
  /SELECT ALL
  /DESTINATION VIEWER=NO
  /TAG='HideXModelsAB_FinalRun'.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /DEPENDENT OSSLT_Sqrt
  /METHOD=ENTER School_Type_Public School_Language_French
                Special_Ed_Pct Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_X_A) RESID(Res_X_A).

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /DEPENDENT OSSLT_Sqrt
  /METHOD=ENTER School_Type_Public School_Language_French
                Special_Ed_Pct Special_Ed_Sq Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_X_B) RESID(Res_X_B).

OMSEND TAG='HideXModelsAB_FinalRun'.

OMS
  /SELECT TEXTS
  /DESTINATION VIEWER=NO
  /TAG='HideRegTexts_ModelC_FinalRun'.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /DEPENDENT OSSLT_Sqrt
  /METHOD=ENTER School_Language_French
                Special_Ed_Pct Special_Ed_Sq Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_X_C) RESID(Res_X_C)
        ZRESID(ZRes_X_C) SRESID(SRes_X_C)
        COOK(Cook_X_C) LEVER(Lev_X_C)
        DFFIT(DFFIT_X_C) SDBETA(SDBETA_X_C).

OMSEND TAG='HideRegTexts_ModelC_FinalRun'.

OMS
  /SELECT ALL
  /DESTINATION VIEWER=NO
  /TAG='HideXModelD_FinalRun'.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /DEPENDENT OSSLT_Sqrt
  /METHOD=ENTER School_Language_French
                Special_Ed_Pct Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_X_D) RESID(Res_X_D).

OMSEND TAG='HideXModelD_FinalRun'.


* ============================================================.
* Block 7: Manual RSS, AIC, and BIC for X-transformation models.
* Output reshaped to long format.
* ============================================================.

COMPUTE RSS_X_A_i = Res_X_A ** 2.
COMPUTE RSS_X_B_i = Res_X_B ** 2.
COMPUTE RSS_X_C_i = Res_X_C ** 2.
COMPUTE RSS_X_D_i = Res_X_D ** 2.
EXECUTE.

DATASET DECLARE XTransform_Metrics.

AGGREGATE
  /OUTFILE='XTransform_Metrics'
  /BREAK=
  /N_A=N(RSS_X_A_i)
  /RSS_A=SUM(RSS_X_A_i)
  /N_B=N(RSS_X_B_i)
  /RSS_B=SUM(RSS_X_B_i)
  /N_C=N(RSS_X_C_i)
  /RSS_C=SUM(RSS_X_C_i)
  /N_D=N(RSS_X_D_i)
  /RSS_D=SUM(RSS_X_D_i).

DATASET ACTIVATE XTransform_Metrics.

COMPUTE K_A = 7.
COMPUTE K_B = 8.
COMPUTE K_C = 7.
COMPUTE K_D = 6.

COMPUTE AIC_A =
  N_A*(LN(2*3.141592653589793)+1+LN(RSS_A/N_A)) + 2*K_A.
COMPUTE BIC_A =
  N_A*(LN(2*3.141592653589793)+1+LN(RSS_A/N_A)) + LN(N_A)*K_A.

COMPUTE AIC_B =
  N_B*(LN(2*3.141592653589793)+1+LN(RSS_B/N_B)) + 2*K_B.
COMPUTE BIC_B =
  N_B*(LN(2*3.141592653589793)+1+LN(RSS_B/N_B)) + LN(N_B)*K_B.

COMPUTE AIC_C =
  N_C*(LN(2*3.141592653589793)+1+LN(RSS_C/N_C)) + 2*K_C.
COMPUTE BIC_C =
  N_C*(LN(2*3.141592653589793)+1+LN(RSS_C/N_C)) + LN(N_C)*K_C.

COMPUTE AIC_D =
  N_D*(LN(2*3.141592653589793)+1+LN(RSS_D/N_D)) + 2*K_D.
COMPUTE BIC_D =
  N_D*(LN(2*3.141592653589793)+1+LN(RSS_D/N_D)) + LN(N_D)*K_D.
EXECUTE.

OMS
  /SELECT ALL
  /DESTINATION VIEWER=NO
  /TAG='HideVarstocases_X_FinalRun'.

VARSTOCASES
  /MAKE N FROM N_A N_B N_C N_D
  /MAKE RSS FROM RSS_A RSS_B RSS_C RSS_D
  /MAKE AIC FROM AIC_A AIC_B AIC_C AIC_D
  /MAKE BIC FROM BIC_A BIC_B BIC_C BIC_D
  /INDEX=Predictor_Model(4)
  /NULL=KEEP.

OMSEND TAG='HideVarstocases_X_FinalRun'.

VALUE LABELS Predictor_Model
  1 "A: Sqrt, original predictors"
  2 "B: Add Special Ed squared"
  3 "C: Drop School Type + squared"
  4 "D: Drop School Type only".

VARIABLE LABELS
  Predictor_Model "Predictor model"
  N "N"
  RSS "RSS"
  AIC "AIC"
  BIC "BIC".

FORMATS N (F5.0) RSS AIC BIC (F12.4).

LIST VARIABLES=Predictor_Model N RSS AIC BIC.

DATASET ACTIVATE OSSLT_RAW.
DATASET CLOSE XTransform_Metrics.


* ============================================================.
* Block 8: Influence and outlier diagnostics for selected model.
* Compact version: flag summary only.
* Removed case IDs are documented in Block 9.
* ============================================================.

COMPUTE Abs_ZRes_X_C = ABS(ZRes_X_C).
COMPUTE Abs_SRes_X_C = ABS(SRes_X_C).

COMPUTE N_Model_C = 737.
COMPUTE P_Model_C = 6.

COMPUTE StdResid_Threshold = 4.
COMPUTE StudResid_Threshold = 3.
COMPUTE Lev_Threshold = 2*(P_Model_C + 1)/N_Model_C.
COMPUTE Cook_Threshold = 4/N_Model_C.
COMPUTE DFFIT_Threshold = 2*SQRT(P_Model_C/N_Model_C).
COMPUTE SDBETA_Threshold = 2/SQRT(N_Model_C).

COMPUTE Flag_StdResid = (Abs_ZRes_X_C > StdResid_Threshold).
COMPUTE Flag_StudResid = (Abs_SRes_X_C > StudResid_Threshold).
COMPUTE Flag_Leverage = (Lev_X_C > Lev_Threshold).
COMPUTE Flag_Cook = (Cook_X_C > Cook_Threshold).
COMPUTE Flag_DFFIT = (ABS(DFFIT_X_C) > DFFIT_Threshold).
EXECUTE.

VARIABLE LABELS
  Flag_StdResid "Flag: |standardized residual| > 4"
  Flag_StudResid "Flag: |studentized residual| > 3"
  Flag_Leverage "Flag: high leverage"
  Flag_Cook "Flag: Cook's D > 4/n"
  Flag_DFFIT "Flag: high DFFITS".

VALUE LABELS Flag_StdResid Flag_StudResid Flag_Leverage Flag_Cook Flag_DFFIT
  0 "No"
  1 "Yes".

FREQUENCIES VARIABLES=
  Flag_StdResid Flag_StudResid Flag_Leverage Flag_Cook Flag_DFFIT.


* ============================================================.
* Block 9: Remove selected influential/outlier cases and fit final model.
* Removed cases:
* 211, 385, 102, 118, 225, 484, 486, 488, 533.
* ============================================================.

USE ALL.
COMPUTE Keep_Final =
  NOT ANY(Clean_Case_ID, 211, 385, 102, 118, 225, 484, 486, 488, 533).
FILTER BY Keep_Final.
EXECUTE.

VARIABLE LABELS Keep_Final "Final model filter".

VALUE LABELS Keep_Final
  0 "Removed"
  1 "Kept".

OMS
  /SELECT TEXTS
  /DESTINATION VIEWER=NO
  /TAG='HideRegTexts_FinalModel_FinalRun'.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT OSSLT_Sqrt
  /METHOD=ENTER School_Language_French
                Special_Ed_Pct Special_Ed_Sq Low_Income_Pct No_Parent_Degree_Pct
  /SAVE PRED(Pred_Final) RESID(Res_Final)
        ZRESID(ZRes_Final) SRESID(SRes_Final)
        COOK(Cook_Final) LEVER(Lev_Final) DFFIT(DFFIT_Final).

OMSEND TAG='HideRegTexts_FinalModel_FinalRun'.


* ============================================================.
* Block 10: Before-vs-after final model performance comparison.
* ============================================================.

FILTER OFF.
EXECUTE.

COMPUTE RSS_BeforeFinal_i = Res_X_C ** 2.
EXECUTE.

FILTER BY Keep_Final.
EXECUTE.

COMPUTE RSS_Final_i = Res_Final ** 2.
EXECUTE.

FILTER OFF.
EXECUTE.

DATASET DECLARE Final_Metrics.

AGGREGATE
  /OUTFILE='Final_Metrics'
  /BREAK=
  /N_Before=N(RSS_BeforeFinal_i)
  /RSS_Before=SUM(RSS_BeforeFinal_i)
  /N_Final=N(RSS_Final_i)
  /RSS_Final=SUM(RSS_Final_i).

DATASET ACTIVATE Final_Metrics.

COMPUTE K_Before = 7.
COMPUTE K_Final = 7.

COMPUTE AIC_Before =
  N_Before*(LN(2*3.141592653589793)+1+LN(RSS_Before/N_Before)) + 2*K_Before.
COMPUTE BIC_Before =
  N_Before*(LN(2*3.141592653589793)+1+LN(RSS_Before/N_Before)) + LN(N_Before)*K_Before.

COMPUTE AIC_Final =
  N_Final*(LN(2*3.141592653589793)+1+LN(RSS_Final/N_Final)) + 2*K_Final.
COMPUTE BIC_Final =
  N_Final*(LN(2*3.141592653589793)+1+LN(RSS_Final/N_Final)) + LN(N_Final)*K_Final.

COMPUTE Sigma_Before = SQRT(RSS_Before / (N_Before - 6)).
COMPUTE Sigma_Final = SQRT(RSS_Final / (N_Final - 6)).
EXECUTE.

OMS
  /SELECT ALL
  /DESTINATION VIEWER=NO
  /TAG='HideVarstocases_Final_FinalRun'.

VARSTOCASES
  /MAKE N FROM N_Before N_Final
  /MAKE RSS FROM RSS_Before RSS_Final
  /MAKE AIC FROM AIC_Before AIC_Final
  /MAKE BIC FROM BIC_Before BIC_Final
  /MAKE Sigma FROM Sigma_Before Sigma_Final
  /INDEX=Final_Comparison(2)
  /NULL=KEEP.

OMSEND TAG='HideVarstocases_Final_FinalRun'.

VALUE LABELS Final_Comparison
  1 "Before outlier removal"
  2 "After outlier removal".

VARIABLE LABELS
  Final_Comparison "Final comparison"
  N "N"
  RSS "RSS"
  AIC "AIC"
  BIC "BIC"
  Sigma "Residual SE".

FORMATS N (F5.0) RSS AIC BIC Sigma (F12.4).

LIST VARIABLES=Final_Comparison N RSS AIC BIC Sigma.

DATASET ACTIVATE OSSLT_RAW.
DATASET CLOSE Final_Metrics.

FILTER BY Keep_Final.
EXECUTE.

GRAPH
  /SCATTERPLOT(BIVAR)=Pred_Final WITH Res_Final
  /TITLE='Final Model: Residuals vs Fitted After Outlier Removal'.

FILTER OFF.
EXECUTE.


* ============================================================.
* Block 11: Save final model dataset.
* ============================================================.

FILTER BY Keep_Final.
EXECUTE.

SAVE OUTFILE='D:\302_OSSLT_DASH\OSSLT_final_model_SPSS.sav'
  /COMPRESSED.
EXECUTE.

OMSEND TAG='NoNotes_FinalRun'.
OMSEND TAG='HideRegressionJunk_FinalRun'.

FILTER OFF.
EXECUTE.

DATASET CLOSE OSSLT_RAW.

OUTPUT EXPORT
  /PDF DOCUMENTFILE='D:\302_OSSLT_DASH\OSSLT_SPSS_Output_Clean.pdf'.

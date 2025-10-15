# NHANES Dataset - Derived Variables and KDM Implementation

This document describes the custom derived variables and KDM biological age calculations in the comprehensive NHANES dataset.

## Dataset Overview

- **Years**: 2009, 2011, 2013, 2015, 2017 (NHANES cycles F, G, H, I, J)
- **Primary Purpose**: Biological age calculation using the Klemera-Doubal Method (KDM)
- **Base Data**: NHANES III, NHANES IV with custom derived variables

## Filtering Criteria

### Participant Inclusion
- **Age Range**: 30-75 years (paper requirement)
- **Exclusions**: 
  - Children (<18 years)
  - Pregnant females
  - Missing biomarker data

### Biomarker Selection Criteria
1. **Age Correlation**: r > 0.10 with chronological age
2. **Multi-collinearity**: r < 0.7 between biomarkers
3. **Data Availability**: >50% complete cases
4. **Outlier Handling**: Values >5 SD from sex-specific mean excluded

## KDM Biological Age Variables

| Variable Name | Description | Type | Source |
|---------------|-------------|------|---------|
| `KDM_BIOAGE` | Calculated biological age using KDM | Float | Custom |
| `KDM_ADVANCE` | Biological age advancement (bioage - chronological age) | Float | Custom |

## Derived Biomarkers (KDM Implementation)

These variables are calculated from original NHANES variables to support biological age calculations.

| Variable Name | Description | Formula | Purpose |
|---------------|-------------|---------|---------|
| `nonhdl` | Non-HDL cholesterol | `totchol - hdl` | Cardiovascular risk marker |
| `pp` | Pulse pressure | `sbp - dbp` | Arterial stiffness indicator |
| `acr` | Albumin-to-creatinine ratio | `albumin / creat` | Kidney function marker |
| `alt` | ALT proxy using GGT | `ggt` (as proxy) | Liver function marker |

## Derived Variables (Data Processing)

Additional calculated variables for analysis and standardization.

| Variable Name | Description | Formula | Purpose |
|---------------|-------------|---------|---------|
| `meanbp` | Mean blood pressure | `(sbp + 2*dbp)/3` | Alternative BP measure |
| `pulse` | Alternative pulse pressure | `sbp - dbp` | Arterial stiffness |
| `fev_1000` | FEV1 in liters | `fev / 1000` | Standardized lung function |
| `albumin_gL` | Albumin in g/L | `albumin * 10` | SI unit conversion |
| `lnalp` | Log-transformed ALP | `log(alp + 1)` | Normalize distribution |
| `lnbun` | Log-transformed BUN | `log(bun + 1)` | Normalize distribution |
| `creat_umol` | Creatinine in μmol/L | `creat * 88.4017` | SI unit conversion |
| `lncreat` | Log-transformed creatinine | `log(creat + 1)` | Normalize distribution |
| `lncreat_umol` | Log-transformed creatinine (μmol/L) | `log(creat_umol + 1)` | Normalize distribution |
| `glucose_mmol` | Glucose in mmol/L | `glucose * 0.0555` | SI unit conversion |
| `lnuap` | Log-transformed uric acid | `log(uap + 1)` | Normalize distribution |
| `crp_cat` | CRP categories | Categorical based on CRP levels | Clinical interpretation |
| `lncrp` | Log-transformed CRP | `log(crp + 1)` | Normalize distribution |
| `lnhba1c` | Log-transformed HbA1c | `log(hba1c + 1)` | Normalize distribution |
| `grip_scaled` | Scaled grip strength | Normalized grip strength | Physical function |
| `lnwalk` | Log-transformed walking speed | `log(walk + 1)` | Normalize distribution |

## KDM Implementation Details

### Initial Biomarkers (15)
```python
initial_biomarkers = {
    'bun': 'Blood Urea Nitrogen',
    'creat': 'Serum Creatinine', 
    'albumin': 'Albumin',
    'alt': 'Alanine Aminotransferase',
    'wbc': 'White Blood Cell Count',
    'totchol': 'Total Cholesterol',
    'hdl': 'High-Density Lipoprotein Cholesterol',
    'nonhdl': 'Non-HDL Cholesterol',
    'hba1c': 'Glycosylated Hemoglobin',
    'waist': 'Waist Circumference',
    'bmi': 'Body Mass Index',
    'sbp': 'Systolic Blood Pressure',
    'pp': 'Pulse Pressure',
    'alp': 'Alkaline Phosphatase',
    'acr': 'Albumin-to-Creatinine Ratio'
}
```

### Final Selection Process
1. **Correlation Analysis**: Select biomarkers with |r| > 0.10 with age
2. **Multi-collinearity Check**: Remove one from each pair with r > 0.7
3. **Sex-Specific Models**: Separate calculations for males and females
4. **Minimum Requirement**: At least 3 biomarkers needed for KDM calculation

## Usage Notes

- **Variable Names**: Use the descriptive names (e.g., `nonhdl`, `pp`) in analysis
- **Missing Data**: Derived variables inherit missing data from source variables
- **Units**: Most derived variables maintain clinical interpretability
- **Transformations**: Log transformations use log(x+1) to handle zero values

---

*This documentation covers the custom derived variables and KDM implementation. For original NHANES variables, refer to the official NHANES documentation.*

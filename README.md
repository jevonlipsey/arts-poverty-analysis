# US Arts Participation and Socioeconomic Status Analysis

<img width="720" height="375" alt="image" src="https://github.com/user-attachments/assets/9115cdde-479a-452d-8596-29541194eb12" />

## Project Overview
This repository contains the R code for a statistical analysis examining the association between **state-level poverty** and **individual participation in arts and cultural activities** across the United States, using 2012 survey data.

The project defines two distinct groups—"High Poverty" and "Low Poverty" states—based on student eligibility for free and reduced-price lunch. The analysis uses visualization and hypothesis testing to identify statistically significant differences in participation means between these groups.

## Data Sources
This analysis utilizes two primary datasets:
1.  **Free/Reduced Lunch Eligibility Data:** Used to establish the socioeconomic status (poverty category) of each U.S. state.
2.  **Individual Arts Participation Survey Data (2012):** Used to measure individual engagement in various activities (e.g., attending ballet, jazz concerts, or craft fairs).

*(Note: Data files were cleaned in Excel/R for state code consistency and numerical conversion prior to this script.)*

## Key Findings & Conclusion
The analysis employed two-sample t-tests to evaluate the Null Hypothesis ($H_0$): *There is no difference in mean arts participation between high and low poverty states.*

| Activity Type | Participation Metric | Statistical Outcome |
| :--- | :--- | :--- |
| **DANCE** | Binary (Yes/No) | **Reject $H_0$** (Statistically Significant) |
| **SALSA** | Binary (Yes/No) | **Reject $H_0$** (Statistically Significant) |
| **SALSA_N** | Frequency (Times/Year) | **Reject $H_0$** (Statistically Significant) |
| **MUSICAL_N** | Frequency (Times/Year) | **Reject $H_0$** (Statistically Significant) |

**Conclusion:** The results provide evidence that while overall participation rates may not differ significantly across the board, individuals in **higher poverty states** who engage in activities like **Salsa** and **Musicals** do so with a statistically significant **higher frequency** than those in low-poverty states.

## Files
* **`statsfinal.R`**: The complete R script performing data loading, cleaning, state classification, visualization (`ggplot2`), and two-sample t-tests.

## Required Libraries
The script requires the following R packages:
* `readxl`
* `ggplot2`

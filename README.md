# Desert Rodent Population Dynamics

## Overview

This project investigates population dynamics and the influence of rainfall on desert rodent abundance using long-term ecological monitoring data from the Portal Project in Arizona, USA.

The analyses examine temporal changes in rodent abundance, population growth, density dependence and the relationship between rainfall and population growth.

All analyses are contained in a single R script.

## Data

Data are obtained from the [Portal Project](https://portal.weecology.org/), a long-term ecological research project monitoring desert rodent communities and environmental conditions.

The analysis uses rodent abundance and precipitation data accessed through the `portalr` R package.

## Analyses

### Population dynamics

Annual abundance indices are calculated from rodent survey data. Changes in abundance are visualised over time, and annual per-capita population growth rates are estimated.

Density-dependent and density-independent population growth models are fitted and compared using Akaike's Information Criterion (AIC).

Where the fitted parameters are consistent with logistic growth, a carrying-capacity parameter is estimated and used to generate a 30-year population projection.

### Environmental effects on population growth

Annual rainfall is calculated from monthly precipitation records and combined with the population data.

Linear models are used to investigate whether rainfall explains variation in population growth after accounting for population size. Models with and without rainfall are compared using AIC and analysis of variance.

### Model diagnostics

Residual diagnostics and autocorrelation plots are used to examine model assumptions and identify potential temporal structure in the data.

## Methods

Analyses are conducted in R using data processing, linear regression, model comparison, logistic population projections and ecological data visualisation.

## R packages

- `portalr`
- `dplyr`
- `tidyr`
- `ggplot2`

## Running the analysis

Install the required packages:

```r
install.packages(c("portalr", "dplyr", "tidyr", "ggplot2"))
```

Download the R script and run it in RStudio. The script retrieves ecological monitoring data, generates plots and model summaries, and saves processed results as CSV files.

## Limitations

Annual rodent abundance is represented by mean survey counts rather than estimates of absolute population size. Differences in sampling effort, detection probability and community composition may influence the observed patterns.

The logistic model provides an exploratory assessment of density dependence. Carrying-capacity estimates and projections depend on the fitted model and should not be interpreted as definitive estimates of ecological carrying capacity.

Rainfall effects are assessed using annual precipitation, although seasonal or lagged environmental conditions may also influence population dynamics.

## Data source

Portal Project: [https://portal.weecology.org/](https://portal.weecology.org/)

R package: [portalr](https://weecology.github.io/portalr/)

The original Portal Project data publications and package should be cited when using these data.

# install.packages(c("portalr", "dplyr", "tidyr", "ggplot2"))

library(portalr)
library(dplyr)
library(tidyr)
library(ggplot2)

# Load data
portalr::download_observations(".")

rodents <- portalr::abundance(
  path = ".",
  level = "plot",
  time = "date",
  shape = "crosstab"
)

climate <- portalr::weather(
  level = "monthly",
  path = ".",
  fill = FALSE
)

head(rodents)
head(climate)


# Annual rodent abundance
survey_data <- rodents %>%
  pivot_longer(
    cols = -c(censusdate, treatment, plot),
    names_to = "Species",
    values_to = "Abundance"
  ) %>%
  group_by(censusdate) %>%
  summarise(
    Count = sum(Abundance, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(Year = as.integer(format(censusdate, "%Y")))

population <- survey_data %>%
  group_by(Year) %>%
  summarise(
    Count = mean(Count),
    Surveys = n(),
    .groups = "drop"
  ) %>%
  filter(Surveys >= 6, Count > 0) %>%
  arrange(Year)

head(population)


# Population trends
ggplot(population, aes(Year, Count)) +
  geom_line(colour = "steelblue", linewidth = 1) +
  geom_point(size = 1.5) +
  theme_classic() +
  labs(
    title = "Desert rodent abundance",
    x = "Year",
    y = "Mean count per survey"
  )


# Annual population growth
population <- population %>%
  mutate(
    NextYear = lead(Year),
    NextCount = lead(Count),
    GrowthRate = (NextCount - Count) / Count
  ) %>%
  filter(NextYear == Year + 1)

summary(population)


# Density-dependent and density-independent growth
logistic_model <- lm(GrowthRate ~ Count, data = population)
exponential_model <- lm(GrowthRate ~ 1, data = population)

summary(logistic_model)
summary(exponential_model)

AIC(exponential_model, logistic_model)


# Growth rate and carrying capacity
r_est <- unname(coef(logistic_model)[1])
slope <- unname(coef(logistic_model)[2])

cat("Estimated growth rate:", round(r_est, 3), "\n")

if (r_est > 0 && slope < 0) {
  
  K_est <- -r_est / slope
  
  cat("Estimated carrying capacity:", round(K_est, 2), "\n")
  
} else {
  
  K_est <- NA_real_
  
  cat("Carrying capacity could not be estimated.\n")
  
}


# Logistic population projection
if (!is.na(K_est)) {
  
  years <- 30
  N <- numeric(years + 1)
  N[1] <- tail(population$NextCount, 1)
  
  for (t in 1:years) {
    N[t + 1] <- N[t] +
      r_est * N[t] * (1 - N[t] / K_est)
  }
  
  projection <- data.frame(
    Year = 0:years,
    Count = N
  )
  
  ggplot(projection, aes(Year, Count)) +
    geom_line(colour = "steelblue", linewidth = 1) +
    geom_hline(
      yintercept = K_est,
      colour = "red",
      linetype = "dashed"
    ) +
    theme_classic() +
    labs(
      title = "Logistic population projection",
      x = "Years after final observation",
      y = "Projected mean count per survey"
    )
  
}


# Density dependence
ggplot(population, aes(Count, GrowthRate)) +
  geom_point(size = 2) +
  geom_smooth(
    method = "lm",
    se = TRUE,
    colour = "steelblue"
  ) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme_classic() +
  labs(
    title = "Density-dependent population growth",
    x = "Mean count per survey",
    y = "Annual per-capita growth rate"
  )


# Model diagnostics
par(mfrow = c(2, 2))
plot(logistic_model)
par(mfrow = c(1, 1))

acf(residuals(logistic_model))


# Rainfall and population growth

# Annual rainfall
rainfall <- climate %>%
  group_by(year) %>%
  summarise(
    Rainfall = if (
      n_distinct(month[!is.na(precipitation)]) == 12
    ) {
      sum(precipitation, na.rm = TRUE)
    } else {
      NA_real_
    },
    .groups = "drop"
  ) %>%
  rename(Year = year) %>%
  filter(!is.na(Rainfall))

head(rainfall)


# Combine population and rainfall data
population_env <- population %>%
  left_join(rainfall, by = "Year") %>%
  filter(!is.na(Rainfall))

head(population_env)


# Model population growth with and without rainfall
model_density <- lm(
  GrowthRate ~ Count,
  data = population_env
)

model_environment <- lm(
  GrowthRate ~ Count + Rainfall,
  data = population_env
)

summary(model_environment)

AIC(model_density, model_environment)
anova(model_density, model_environment)


# Rainfall and population growth
ggplot(population_env, aes(Rainfall, GrowthRate)) +
  geom_point(size = 2) +
  geom_smooth(
    method = "lm",
    se = TRUE,
    colour = "steelblue"
  ) +
  theme_classic() +
  labs(
    title = "Rainfall and rodent population growth",
    x = "Annual rainfall (mm)",
    y = "Annual per-capita growth rate"
  )


# Annual rainfall
ggplot(rainfall, aes(Year, Rainfall)) +
  geom_col(fill = "steelblue") +
  theme_classic() +
  labs(
    title = "Annual rainfall",
    x = "Year",
    y = "Rainfall (mm)"
  )


# Model diagnostics
par(mfrow = c(2, 2))
plot(model_environment)
par(mfrow = c(1, 1))

acf(residuals(model_environment))


# Save results
dir.create("results", showWarnings = FALSE)

write.csv(
  population,
  "results/rodent_population.csv",
  row.names = FALSE
)

write.csv(
  population_env,
  "results/rodent_population_rainfall.csv",
  row.names = FALSE
)

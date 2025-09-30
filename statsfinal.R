# data preparation
# datasets downloaded and cleaned on microsoft excel beforehand
install.packages("readxl")
library(readxl)
participation <- load("Downloads/35596-0001-Data.rda")
lunches <- read_excel("Downloads/lunches2012-13 clean.xlsx")

# Add a new column classifying states by poverty
lunches$`Poverty Category` <- ifelse(lunches$`Percent Eligible` > 50, 
                                     "High Poverty", "Low Poverty")
# focus on 2012 participation data to match lunches data and has location
participation2012 <- subset(da35596.0001, YEAR == 2012 & !is.na(FIPS_STATE))

# plot lunches percentage of eligible students by state
library(ggplot2)
ggplot(lunches, aes(x = reorder(State, `Percent Eligible`),
                    y = `Percent Eligible`, fill = `Poverty Category`)) +
  # highlight U.S
  geom_bar(stat = "identity", aes(color = ifelse(State == "United States",
                                                 "highlight", "normal"))) +  
  scale_color_manual(values = c("highlight" = "black", 
                                "normal" = "transparent"), guide = "none") +  
  # legend
  scale_fill_manual(values = c("High Poverty" = "orange",
                               "Low Poverty" = "blue"),
                    name = "Poverty Category") + 
  coord_flip() +
  # labels
  labs(title = "Percentage of Eligible Students for Free/Reduced Lunch by State", 
       x = "State",
       y = "Percent Eligible") +
  theme_minimal() +
  # label U.S. average
  geom_text(aes(label = ifelse(State == "United States", "U.S. Avg - 51.3%", "")),
            hjust = -0.3)  

# high poverty states (derived from lunches)
high_poverty <- c("AL", "AZ", "AR", "CA", "DE", "DC", "FL", "GA", "HI", "IL",
                  "KY", "LA", "MS", "NV", "NM", "NC", "OK", "OR", "SC", "TN",
                  "TX", "UT", "WV")
# low poverty states
low_poverty <- c("AK", "CO", "CT", "ID", "IN", "IA", "KS", "ME", "MD", "MA", 
                 "MI", "MN", "MO", "MT", "NE", "NH", "NJ", "NY", "ND", "OH", 
                 "PA", "RI", "SD", "VT", "VA", "WA", "WI", "WY")

# now, we can handle participation 
# use sub to remove numerical codes from state codes
participation2012$FIPS_STATE <- sub(".*\\)\\s*", "", participation2012$FIPS_STATE)

# sort participation by arts, both yes/no and numerical
arts_vars <- c("FESTIVAL", "CRAFT_FAIR", "ARTMUSEUM", "PARK", "BALLET", "CLASSICAL", 
               "DANCE", "JAZZ", "SALSA", "MUSICAL", "PLAY", "OPERA", "BOOKS")
arts_n_vars <- c("ARTMUSEUM_N", "BALLET_N", "CLASSICAL_N", "JAZZ_N", "SALSA_N", 
                 "MUSICAL_N", "PLAY_N", "OPERA_N", "DANCE_N", "PARK_N", "CRAFT_FAIR_N")

# turn all variables to numeric - turn (1) Yes and (2) No to 1/0
participation2012[arts_vars] <- lapply(participation2012[arts_vars], function(x) {
  ifelse(grepl("\\(1\\)", x), 1, ifelse(grepl("\\(2\\)", x), 0, NA))
})
participation2012[arts_n_vars] <- lapply(participation2012[arts_n_vars], function(x) {
  as.numeric(x)
})

# now, sort participation
high_participation <- subset(participation2012, FIPS_STATE %in% high_poverty)
low_participation <- subset(participation2012, FIPS_STATE %in% low_poverty)

# calculate means for binary arts participation (yes/no)
high_poverty_means <- colMeans(high_participation[arts_vars], na.rm = TRUE)
low_poverty_means <- colMeans(low_participation[arts_vars], na.rm = TRUE)

# calculate means for frequency-based arts participation
high_poverty_n_means <- colMeans(high_participation[arts_n_vars], na.rm = TRUE)
low_poverty_n_means <- colMeans(low_participation[arts_n_vars], na.rm = TRUE)

# data frame for binary participation means
arts_means_binary <- data.frame(
  art_type = rep(arts_vars, 2),
  poverty_level = rep(c("High Poverty", "Low Poverty"), each = length(arts_vars)),
  mean = c(high_poverty_means, low_poverty_means)
)

# create bar plot for binary means
ggplot(arts_means_binary, aes(x = art_type, y = mean, fill = poverty_level)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "High Poverty vs Low Poverty Means by Art Type (Binary) Participation in the Last Year",
       x = "Art Type",
       y = "Mean (0-1)",
       fill = "Poverty Level") +
  scale_fill_manual(values = c("High Poverty" = "orange", "Low Poverty" = "blue"))
rm
# data frame for frequency-based participation means
arts_means_frequency <- data.frame(
  art_type = rep(arts_n_vars, 2),
  poverty_level = rep(c("High Poverty", "Low Poverty"), each = length(arts_n_vars)),
  mean = c(high_poverty_n_means, low_poverty_n_means)
)
# Create bar plot for frequency means
ggplot(arts_means_frequency, aes(x = art_type, y = mean, fill = poverty_level)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "High Poverty vs Low Poverty Means by Art Type (Frequency) Participation in the Last Year",
       x = "Art Type",
       y = "Mean Frequency",
       fill = "Poverty Level") +
  scale_fill_manual(values = c("High Poverty" = "orange", "Low Poverty" = "blue"))

# also create wide versions for visualization:
arts_means_binary_wide <- data.frame(
 art_type = arts_vars,
 high_poverty_means = high_poverty_means,
 low_poverty_means = low_poverty_means
)
# frequency:
arts_means_frequency_wide <- data.frame(
 art_type = arts_n_vars,
 high_poverty_means = high_poverty_n_means,
 low_poverty_means = low_poverty_n_means
)



#### HYPOTHETHIS TEST: 2 INDEPENDENT SAMPLES 

# H0: There is no association between poverty level 
#     and arts participation. ( u1 - u2 = 0)

# Ha: There is an association between poverty level 
#     and arts participation. ( u1 - u2 -= 0)

# run t-tests for binary participation variables (art types)
binary_t_test_results <- sapply(arts_vars, function(var) {
  t.test(high_participation[[var]], low_participation[[var]], na.rm = TRUE)
})

# run t-tests for each frequency-based participation variable
# remove two N/A variables from arts_n_vars
clean_arts_n_vars <- arts_n_vars[!(arts_n_vars %in% c("PARK_N", "CRAFT_FAIR_N"))]
# now, run t-tests on the cleaned arts_n_vars
frequency_t_test_results <- sapply(clean_arts_n_vars, function(var) {
  t.test(high_participation[[var]], low_participation[[var]], na.rm = TRUE)
})


# note* t.test is a function that calculates conf int., stderr, and does a two
# note* tailed test using t distribution -
# note* sapply then applies t.test function to all arts vars!


# RESULTS:
# * can click on binary and frequency test results to see everything
# BINARY (YES/NO):
# reject null hypothesis for: DANCE and SALSA
# fail to reject everything else.
# meaning: dance and salsa results are very likely to be sampled again, so we have
#         evidence to say lower poverty states dance more, while higher poverty salsa more in the population*


# FREQUENCY:
# reject null hypothesis for: SALSA_N, MUSICAL_N
# meaning: we have evidence to say that higher poverty states attend salsa more times
#         than low poverty states on average,and same for attending more musicals



# bigger idea: looking at graphs and hypothesis that we rejected, we could say that
# higher poverty people may not have the opportunity to attend at all, but if they do 
# participate in the arts, they attend MORE than those in low poverty.

# even bigger idea: higher poverty have more passions? use arts as more of an escape? idk





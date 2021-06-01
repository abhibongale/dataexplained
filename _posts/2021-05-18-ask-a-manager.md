---
layout: post
title: "Ask a Manager"
description: ""
output: html_document
date: "2021-06-01"
category: r
tags: [r, tidytuesday, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---

![ask-a-manager](https://www.askamanager.org/wp-content/uploads/2019/09/cropped-aam-resize-1-550px_width.png)

*Tidy-Tuesday challenge about the salary survey a few weeks ago.*

Lots of womens living in United States responsed to the salary survey. So we will look into how the state, age, job type, education, experience overall and in the field effects the annual salary. 

Annual salary Forecasts like these are useful because they help us understand the most likely range for certain kind of talent.






{% highlight r %}
survey_raw <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-18/survey.csv')
{% endhighlight %}



{% highlight text %}
## 
## ── Column specification ──────────────────────────────────────────────────────────────
## cols(
##   timestamp = col_character(),
##   how_old_are_you = col_character(),
##   industry = col_character(),
##   job_title = col_character(),
##   additional_context_on_job_title = col_character(),
##   annual_salary = col_double(),
##   other_monetary_comp = col_character(),
##   currency = col_character(),
##   currency_other = col_character(),
##   additional_context_on_income = col_character(),
##   country = col_character(),
##   state = col_character(),
##   city = col_character(),
##   overall_years_of_professional_experience = col_character(),
##   years_of_experience_in_field = col_character(),
##   highest_level_of_education_completed = col_character(),
##   gender = col_character(),
##   race = col_character()
## )
{% endhighlight %}



{% highlight r %}
survey  <- survey_raw %>%
  filter(gender == "Woman", annual_salary >= 5000, annual_salary <= 2e6, currency == "USD",
         !is.na(how_old_are_you)) %>%
  mutate(age_category = fct_reorder(how_old_are_you, parse_number(how_old_are_you)),
         age_category = fct_relevel(age_category,"under 18"),
         overall_experience = fct_reorder(str_replace(overall_years_of_professional_experience, 
                                                     " - ", "-"),
                                        parse_number(overall_years_of_professional_experience)),
         field_experience = fct_reorder(str_replace(years_of_experience_in_field, " - ", "-"),
                                        parse_number(years_of_experience_in_field)),
         education = factor(highest_level_of_education_completed)
         ) %>%
  select(-c(how_old_are_you, 
            years_of_experience_in_field, 
            overall_years_of_professional_experience,
            timestamp, job_title, additional_context_on_income, 
            additional_context_on_job_title, currency, other_monetary_comp, currency_other,
            country, race, gender, highest_level_of_education_completed))
{% endhighlight %}




{% highlight r %}
# effects of industry on annual salary
survey %>%
  filter(!is.na(industry)) %>%
  mutate(industry = fct_lump(industry, 8)) %>%
  lm(annual_salary ~ industry, data = .) %>%
  summary()
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = annual_salary ~ industry, data = .)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -109138  -28037   -8996   16428 1807004 
## 
## Coefficients:
##                                              Estimate Std. Error t value Pr(>|t|)    
## (Intercept)                                     88353       1550  56.987  < 2e-16 ***
## industryComputing or Tech                       30785       1958  15.724  < 2e-16 ***
## industryEducation (Higher Education)           -20781       2006 -10.361  < 2e-16 ***
## industryEngineering or Manufacturing             7314       2310   3.167  0.00154 ** 
## industryGovernment and Public Administration    -5316       2184  -2.434  0.01494 *  
## industryHealth care                              4643       2117   2.193  0.02831 *  
## industryLaw                                     31256       2412  12.958  < 2e-16 ***
## industryNonprofits                             -15116       1980  -7.633 2.42e-14 ***
## industryOther                                   -7920       1682  -4.708 2.52e-06 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 52230 on 17106 degrees of freedom
## Multiple R-squared:  0.08276,	Adjusted R-squared:  0.08233 
## F-statistic: 192.9 on 8 and 17106 DF,  p-value: < 2.2e-16
{% endhighlight %}



{% highlight r %}
survey %>%
  filter(annual_salary > 5000, annual_salary <= 2e6) %>%
  ggplot(aes(log10(annual_salary))) +
  geom_histogram(aes(fill = overall_experience)) +
  scale_x_continuous(label = scales::dollar_format())  +
  facet_wrap(~field_experience)
{% endhighlight %}



{% highlight text %}
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
{% endhighlight %}

![center](/figs/2021-05-18-ask-a-manager/unnamed-chunk-5-1.png)


{% highlight r %}
survey %>%
  ggplot(aes(log(annual_salary))) +
  geom_histogram(fill = "#1380A1") +
  scale_x_log10(label = scales::dollar_format()) +
  labs(x = "Annual Salary in log scale", y = "Frequency")
{% endhighlight %}



{% highlight text %}
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
{% endhighlight %}

![center](/figs/2021-05-18-ask-a-manager/unnamed-chunk-6-1.png)


{% highlight r %}
survey %>%
  mutate(state = fct_lump(state, 10)) %>%
  ggplot(aes(state)) +
  geom_histogram(stat = "count")
{% endhighlight %}



{% highlight text %}
## Warning: Ignoring unknown parameters: binwidth, bins, pad
{% endhighlight %}

![center](/figs/2021-05-18-ask-a-manager/unnamed-chunk-7-1.png)



{% highlight r %}
survey %>%
  filter(!is.na(industry)) %>%
  mutate(industry = fct_lump(industry, 8),
         state = fct_lump(state, 8)) %>%
  glm(annual_salary ~ industry + field_experience + overall_experience + age_category + state + education, data = .) %>%
  summary()
{% endhighlight %}



{% highlight text %}
## 
## Call:
## glm(formula = annual_salary ~ industry + field_experience + overall_experience + 
##     age_category + state + education, data = .)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -139673   -22829    -5583    14594  1775038  
## 
## Coefficients:
##                                              Estimate Std. Error t value Pr(>|t|)    
## (Intercept)                                   94032.9    19790.5   4.751 2.04e-06 ***
## industryComputing or Tech                     28093.3     1799.5  15.612  < 2e-16 ***
## industryEducation (Higher Education)         -30767.3     1887.4 -16.302  < 2e-16 ***
## industryEngineering or Manufacturing           7373.4     2121.5   3.476 0.000511 ***
## industryGovernment and Public Administration -14935.4     2026.3  -7.371 1.78e-13 ***
## industryHealth care                            -905.9     1944.8  -0.466 0.641340    
## industryLaw                                   -2966.8     2472.8  -1.200 0.230247    
## industryNonprofits                           -23016.4     1835.1 -12.542  < 2e-16 ***
## industryOther                                 -9925.7     1541.2  -6.440 1.22e-10 ***
## field_experience2-4 years                      7818.1     2167.2   3.608 0.000310 ***
## field_experience5-7 years                     16556.8     2238.1   7.398 1.45e-13 ***
## field_experience8-10 years                    24813.2     2318.3  10.703  < 2e-16 ***
## field_experience11-20 years                   33914.6     2348.5  14.441  < 2e-16 ***
## field_experience21-30 years                   47272.8     2898.6  16.309  < 2e-16 ***
## field_experience31-40 years                   51680.1     4511.3  11.456  < 2e-16 ***
## field_experience41 years or more              36045.4    11803.9   3.054 0.002264 ** 
## overall_experience2-4 years                   -9133.4     3679.9  -2.482 0.013075 *  
## overall_experience5-7 years                   -5910.6     3808.9  -1.552 0.120730    
## overall_experience8-10 years                  -3843.0     3839.3  -1.001 0.316860    
## overall_experience11-20 years                  -522.7     3911.3  -0.134 0.893685    
## overall_experience21-30 years                 -1435.7     4194.6  -0.342 0.732157    
## overall_experience31-40 years                 -1933.6     4993.2  -0.387 0.698575    
## overall_experience41 years or more            -6368.2     7796.3  -0.817 0.414045    
## age_category18-24                            -10116.8    19545.7  -0.518 0.604746    
## age_category25-34                             -5596.2    19437.7  -0.288 0.773423    
## age_category35-44                             -6652.2    19432.8  -0.342 0.732117    
## age_category45-54                            -10282.9    19437.4  -0.529 0.596794    
## age_category55-64                            -17632.6    19499.8  -0.904 0.365877    
## age_category65 or over                       -11330.3    20321.4  -0.558 0.577155    
## stateDistrict of Columbia                      3696.5     2072.2   1.784 0.074463 .  
## stateIllinois                                -17921.3     1947.4  -9.203  < 2e-16 ***
## stateMassachusetts                           -11552.2     1797.8  -6.426 1.35e-10 ***
## stateNew York                                 -6860.0     1641.2  -4.180 2.93e-05 ***
## statePennsylvania                            -23860.2     2112.4 -11.295  < 2e-16 ***
## stateTexas                                   -20811.2     1931.0 -10.777  < 2e-16 ***
## stateWashington                               -9949.4     2019.6  -4.926 8.46e-07 ***
## stateOther                                   -26952.6     1243.4 -21.676  < 2e-16 ***
## educationHigh School                         -23999.2     3329.6  -7.208 5.92e-13 ***
## educationMaster's degree                       8475.9      847.3  10.003  < 2e-16 ***
## educationPhD                                  30672.8     1799.3  17.047  < 2e-16 ***
## educationProfessional degree (MD, JD, etc.)   53737.4     1987.8  27.034  < 2e-16 ***
## educationSome college                        -14976.3     1614.4  -9.277  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for gaussian family taken to be 2239088537)
## 
##     Null deviance: 4.9457e+13  on 16801  degrees of freedom
## Residual deviance: 3.7527e+13  on 16760  degrees of freedom
##   (313 observations deleted due to missingness)
## AIC: 409462
## 
## Number of Fisher Scoring iterations: 2
{% endhighlight %}



{% highlight r %}
set.seed(2021)
survey_split <- initial_split(survey)
survey_train <- training(survey_split)
survey_test <- testing(survey_split)
{% endhighlight %}

 

{% highlight r %}
survey_recipe <- survey %>%
  recipe(annual_salary ~ .) %>%
  #step_log(annual_salary, base = 10) %>%
  step_unknown(all_nominal()) %>%
  step_other(all_nominal()) %>%
  step_center(all_numeric()) %>%
  step_novel(all_nominal()) %>%
  step_dummy(all_nominal()) %>%
  prep()


survey_train_prep <- bake(survey_recipe, survey_train)
survey_test_prep <- bake(survey_recipe, survey_test)
{% endhighlight %}



{% highlight r %}
lin_reg <- linear_reg(penalty = 0.1) %>%
  set_engine("lm") %>%
    set_mode("regression") 

rf_model <- 
  # specify that the model is a random forest
  rand_forest() %>%
  # select the engine/package that underlies the model
  set_engine("ranger") %>%
  # choose either the continuous regression or binary classification mode
  set_mode("regression")
{% endhighlight %}



{% highlight r %}
lin_workflow <- # new workflow object
 workflow() %>% # use workflow function
 add_recipe(survey_recipe) %>%   # use the new recipe
 add_model(lin_reg)   # add your model spec

rf_workflow <- workflow() %>%
  add_recipe(survey_recipe) %>%
  add_model(rf_model)
{% endhighlight %}



{% highlight r %}
lin_fit <- lin_workflow %>%
  last_fit(survey_split)
{% endhighlight %}



{% highlight text %}
## ! train/test split: preprocessor 1/1: There are new levels in a factor: NA
{% endhighlight %}



{% highlight text %}
## ! train/test split: preprocessor 1/1, model 1/1 (predictions): There are new levels in a factor: NA
{% endhighlight %}



{% highlight r %}
rf_fit <- rf_workflow %>%
  last_fit(survey_split)
{% endhighlight %}



{% highlight text %}
## ! train/test split: preprocessor 1/1: There are new levels in a factor: NA
{% endhighlight %}



{% highlight text %}
## x train/test split: preprocessor 1/1, model 1/1: Error: Missing data in columns: education_PhD.
{% endhighlight %}



{% highlight text %}
## Warning: All models failed. See the `.notes` column.
{% endhighlight %}



{% highlight r %}
lin_prediction <- lin_fit %>%
  collect_predictions()

lin_performance <- lin_fit %>%
  collect_metrics(summarize = TRUE)


rf_prediction <- rf_fit %>%
  collect_predictions()

rf_performance <- rf_fit %>%
  collect_metrics(summarize = TRUE)
{% endhighlight %}


{% highlight r %}
lin_fit %>%
  collect_metrics()
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 4
##   .metric .estimator   .estimate .config             
##   <chr>   <chr>            <dbl> <fct>               
## 1 rmse    standard   65015.      Preprocessor1_Model1
## 2 rsq     standard       0.00589 Preprocessor1_Model1
{% endhighlight %}



{% highlight r %}
rf.model <- rand_forest() %>%
  set_engine(engine = "ranger") %>%
  set_mode(mode = "regression") %>%
  fit(annual_salary ~ ., data  = survey_train_prep)

rf_predict <- rf.model %>%
  predict(survey_test_prep) %>%
  bind_cols(survey_test_prep)
{% endhighlight %}


{% highlight r %}
rf_predict %>%
ggplot(mapping = aes(x = .pred, y = annual_salary)) +
  geom_point(color = '#006EA1', alpha = 0.25) +
  geom_abline(intercept = 0, slope = 1, color = 'orange') +
  labs(title = 'Linear Regression Results -Annual Salary Test Set',
       x = 'Predicted Annual Salary',
       y = 'Actual Annual Salary') +
  scale_x_continuous(labels = scales::dollar_format()) +
  scale_y_continuous(labels = scales::dollar_format())
{% endhighlight %}

![center](/figs/2021-05-18-ask-a-manager/unnamed-chunk-16-1.png)




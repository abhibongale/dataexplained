---
layout: post
title: "Economic Guide to Picking a College Major - A tidy analysis"
description: "All data is from American Community Survey 2010-2012 Public Use Microdata Series. TidyTuesday Challenge published on 2018-10-26"
output: html_document
date: 2020-12-01 10:30:27 -0400
category: r
tags: [r, statistics]
comments: true
---





{% highlight r %}
library(tidyverse)
theme_set(theme_light())
{% endhighlight %}

Attempt of this blog is to practice data analysis and improve myself through watching how data science pioneers do analysis on there data.

# Explore Data


{% highlight r %}
recent_grads <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2018/2018-10-16/recent-grads.csv')
skimr::skim(recent_grads)
{% endhighlight %}


Table: Data summary

|                         |             |
|:------------------------|:------------|
|Name                     |recent_grads |
|Number of rows           |173          |
|Number of columns        |21           |
|_______________________  |             |
|Column type frequency:   |             |
|character                |2            |
|numeric                  |19           |
|________________________ |             |
|Group variables          |None         |


**Variable type: character**

|skim_variable  | n_missing| complete_rate| min| max| empty| n_unique| whitespace|
|:--------------|---------:|-------------:|---:|---:|-----:|--------:|----------:|
|Major          |         0|             1|   5|  65|     0|      173|          0|
|Major_category |         0|             1|   4|  35|     0|       16|          0|


**Variable type: numeric**

|skim_variable        | n_missing| complete_rate|     mean|       sd|    p0|      p25|      p50|      p75|      p100|hist  |
|:--------------------|---------:|-------------:|--------:|--------:|-----:|--------:|--------:|--------:|---------:|:-----|
|Rank                 |         0|          1.00|    87.00|    50.08|     1|    44.00|    87.00|   130.00|    173.00|▇▇▇▇▇ |
|Major_code           |         0|          1.00|  3879.82|  1687.75|  1100|  2403.00|  3608.00|  5503.00|   6403.00|▃▇▅▃▇ |
|Total                |         1|          0.99| 39370.08| 63483.49|   124|  4549.75| 15104.00| 38909.75| 393735.00|▇▁▁▁▁ |
|Men                  |         1|          0.99| 16723.41| 28122.43|   119|  2177.50|  5434.00| 14631.00| 173809.00|▇▁▁▁▁ |
|Women                |         1|          0.99| 22646.67| 41057.33|     0|  1778.25|  8386.50| 22553.75| 307087.00|▇▁▁▁▁ |
|ShareWomen           |         1|          0.99|     0.52|     0.23|     0|     0.34|     0.53|     0.70|      0.97|▂▆▆▇▃ |
|Sample_size          |         0|          1.00|   356.08|   618.36|     2|    39.00|   130.00|   338.00|   4212.00|▇▁▁▁▁ |
|Employed             |         0|          1.00| 31192.76| 50675.00|     0|  3608.00| 11797.00| 31433.00| 307933.00|▇▁▁▁▁ |
|Full_time            |         0|          1.00| 26029.31| 42869.66|   111|  3154.00| 10048.00| 25147.00| 251540.00|▇▁▁▁▁ |
|Part_time            |         0|          1.00|  8832.40| 14648.18|     0|  1030.00|  3299.00|  9948.00| 115172.00|▇▁▁▁▁ |
|Full_time_year_round |         0|          1.00| 19694.43| 33160.94|   111|  2453.00|  7413.00| 16891.00| 199897.00|▇▁▁▁▁ |
|Unemployed           |         0|          1.00|  2416.33|  4112.80|     0|   304.00|   893.00|  2393.00|  28169.00|▇▁▁▁▁ |
|Unemployment_rate    |         0|          1.00|     0.07|     0.03|     0|     0.05|     0.07|     0.09|      0.18|▂▇▆▁▁ |
|Median               |         0|          1.00| 40151.45| 11470.18| 22000| 33000.00| 36000.00| 45000.00| 110000.00|▇▅▁▁▁ |
|P25th                |         0|          1.00| 29501.45|  9166.01| 18500| 24000.00| 27000.00| 33000.00|  95000.00|▇▂▁▁▁ |
|P75th                |         0|          1.00| 51494.22| 14906.28| 22000| 42000.00| 47000.00| 60000.00| 125000.00|▅▇▂▁▁ |
|College_jobs         |         0|          1.00| 12322.64| 21299.87|     0|  1675.00|  4390.00| 14444.00| 151643.00|▇▁▁▁▁ |
|Non_college_jobs     |         0|          1.00| 13284.50| 23789.66|     0|  1591.00|  4595.00| 11783.00| 148395.00|▇▁▁▁▁ |
|Low_wage_jobs        |         0|          1.00|  3859.02|  6945.00|     0|   340.00|  1231.00|  3466.00|  48207.00|▇▁▁▁▁ |



{% highlight r %}
by_major_category <- majors_processed %>%
  filter(!is.na(Total)) %>%
  group_by(Major_category) %>%
  summarise(Men = sum(Men),
            Women = sum(Women),
            Total = sum(Total),
            MedianSalary = sum(Median * Sample_size) / sum(Sample_size)) %>%
  mutate(ShareWomen = Women / Total) %>%
  arrange(desc(ShareWomen))
{% endhighlight %}



{% highlight text %}
## Error in filter(., !is.na(Total)): object 'majors_processed' not found
{% endhighlight %}

### What are trending Major Category?


{% highlight r %}
recent_grads %>%
  count(Major_category, wt = Total, sort = TRUE) %>%
  mutate(Major_category = fct_reorder(Major_category, n)) %>%
  ggplot(aes(Major_category, n, fill = Major_category)) +
  geom_col() +
  coord_flip() +
  labs( x = "",
        y = "Total # of graduates") +
  theme(legend.position = "none")
{% endhighlight %}

![center](/figs/2018-10-16-economic-guide-to-picking-a-college-major/unnamed-chunk-3-1.png)



Lets look at the median

{% highlight r %}
recent_grads %>%
  ggplot(aes(Median)) +
  geom_histogram()
{% endhighlight %}

![center](/figs/2018-10-16-economic-guide-to-picking-a-college-major/unnamed-chunk-4-1.png)

### How majors-money distribution?


{% highlight r %}
recent_grads %>%
  group_by(Major_category) %>%
  summarise(Median = median(Median)) %>%
  mutate(Major_category = fct_reorder(Major_category, Median)) %>%
  ggplot(aes(Major_category, Median)) +
  geom_col() +
  scale_y_continuous(labels = scales::dollar_format()) +
  coord_flip()
{% endhighlight %}

![center](/figs/2018-10-16-economic-guide-to-picking-a-college-major/unnamed-chunk-5-1.png)

Lets look same thing using boxplot to get more clarity


{% highlight r %}
recent_grads %>%
  mutate(Major_category = fct_reorder(Major_category, Median)) %>%
  ggplot(aes(Major_category, Median, fill = Major_category)) +
  geom_boxplot() +
  scale_y_continuous(labels = scales::dollar_format()) +
  expand_limits(y = 0) +
  coord_flip() +
  theme(legend.position = "none")
{% endhighlight %}

![center](/figs/2018-10-16-economic-guide-to-picking-a-college-major/unnamed-chunk-6-1.png)

### What are the  Highest earning majors?

Lets look at top 20 highest earning majors

{% highlight r %}
recent_grads %>%
  arrange(desc(Median)) %>%
  select(Major, Major_category, Median, P25th, P75th) %>%
  head(20) %>%
  mutate(Major = fct_reorder(Major, Median)) %>%
  ggplot(aes(Major, Median, colour = Major_category)) +
  geom_point() +
  geom_errorbar(aes(ymin = P25th, ymax = P75th)) +
  expand_limits(y = 0) +
  coord_flip() +
  labs(title = "What are the highest-earning majors?",
       subtitle = "Top 20 majors with at least 100 graduates surveyed. Bars represent the 25th to 75th percentile")
{% endhighlight %}

![center](/figs/2018-10-16-economic-guide-to-picking-a-college-major/unnamed-chunk-7-1.png)

`geom_errorbar` shows us the range of the salary. Petroleum engineering 25th percentile salary is greater than the most of the  major 75th percentile salary.

## What are the lowest earning majors?


{% highlight r %}
recent_grads %>%
  arrange(Median) %>%
  select(Major, Major_category, Median, P25th, P75th) %>%
  head(20) %>%
  mutate(Major = fct_reorder(Major, Median)) %>%
  ggplot(aes(Major, Median, colour = Major_category)) +
  geom_point() +
  geom_errorbar(aes(ymin = P25th, ymax = P75th)) +
  expand_limits(y = 0) +
  coord_flip()
{% endhighlight %}

![center](/figs/2018-10-16-economic-guide-to-picking-a-college-major/unnamed-chunk-8-1.png)

We have to look at the sample size if the sample size is low then we don't want to trust that data.


{% highlight r %}
recent_grads %>%
  arrange(Sample_size) %>%
  select(Major, Major_category, Median, P25th, P75th, Sample_size)
{% endhighlight %}



{% highlight text %}
## # A tibble: 173 x 6
##    Major            Major_category       Median P25th  P75th Sample_size
##    <chr>            <chr>                 <dbl> <dbl>  <dbl>       <dbl>
##  1 LIBRARY SCIENCE  Education             22000 20000  22000           2
##  2 METALLURGICAL E… Engineering           73000 50000 105000           3
##  3 PHARMACOLOGY     Biology & Life Scie…  45000 40000  45000           3
##  4 SCHOOL STUDENT … Education             41000 41000  43000           4
##  5 MILITARY TECHNO… Industrial Arts & C…  40000 40000  40000           4
##  6 SOIL SCIENCE     Agriculture & Natur…  35000 18500  44000           4
##  7 GEOLOGICAL AND … Engineering           50000 42800  57000           5
##  8 EDUCATIONAL ADM… Education             34000 29000  35000           5
##  9 MINING AND MINE… Engineering           75000 55000  90000           7
## 10 MATHEMATICS AND… Computers & Mathema…  42000 30000  78000           7
## # … with 163 more rows
{% endhighlight %}


lets look at the median vs sample size graph

{% highlight r %}
recent_grads %>%
  ggplot(aes(Sample_size, Median)) +
  geom_point(aes(colour = Major_category)) +
  geom_text(aes(label = Major), check_overlap = TRUE, vjust = 1, hjust = 1) +
  scale_x_log10()
{% endhighlight %}

![center](/figs/2018-10-16-economic-guide-to-picking-a-college-major/unnamed-chunk-10-1.png)

Major with Sample Size is less than 10. We can see they have lot of variance(stretch) and they are not use full at all they cannot tell the full picture of it.

So we have to set cutoff point for sample size. We should choose good value so that it generalize the data.



{% highlight r %}
recent_grads %>%
  filter(Sample_size >= 100) %>%
  head(20) %>%
  select(Major, Major_category, Median, P25th, P75th) %>%
  ggplot(aes(Major, Median, colour = Major_category)) +
  geom_point() +
  geom_errorbar(aes(ymin = P25th, ymax = P75th)) +
  expand_limits(y = 0) +
  coord_flip()
{% endhighlight %}

![center](/figs/2018-10-16-economic-guide-to-picking-a-college-major/unnamed-chunk-11-1.png)

We should go for Sample size cutoff value 100.


### How does gender breakdown relate to typical earnings?

We will use `gather` function


{% highlight r %}
recent_grads %>%
  arrange(desc(Total)) %>%
  head(20) %>%
  mutate(Major = fct_reorder(Major, Total)) %>%
  gather(Gender, Number, Men, Women) %>%
  select(Major, Gender, Number) %>%
  ggplot(aes(Major, Number, fill = Gender)) +
  geom_col() +
  coord_flip()
{% endhighlight %}

![center](/figs/2018-10-16-economic-guide-to-picking-a-college-major/unnamed-chunk-12-1.png)



### What is a ShareWomen and Average Salary Correlation?

{% highlight r %}
majors_processed <- recent_grads %>%
  arrange(desc(Median)) %>%
  mutate(Major = str_to_title(Major),
         Major = fct_reorder(Major, Median))
{% endhighlight %}



`MedianSalary` is a weighted by `Sample_size`. The more Sample one will have more effect on the outcome.


Lets look at the correlation


{% highlight r %}
by_major_category %>%
  ggplot(aes(ShareWomen, MedianSalary)) +
  geom_point() +
  geom_smooth(method = "lm") +
  ggrepel::geom_text_repel(aes(label = Major_category), forces = 0.1) +
  expand_limits(y = 0)
{% endhighlight %}



{% highlight text %}
## Error in ggplot(., aes(ShareWomen, MedianSalary)): object 'by_major_category' not found
{% endhighlight %}

My first instinct will be Engineering and Computer & Mathematics will be outliers. (they are too away from the center). Health is also a outlier(Simpson paradox).
Seems lik a negative correlation.


{% highlight r %}
g <- majors_processed %>%
  ggplot(aes(ShareWomen, Median)) +
  geom_point(aes(color = Major_category, size = Sample_size, label = Major)) +
  geom_smooth(method = "lm") +
  scale_x_continuous(labels = scales::percent_format()) +
  scale_y_continuous(labels = scales:: dollar_format())
  expand_limits(y = 0)
{% endhighlight %}



{% highlight text %}
## mapping: y = ~y 
## geom_blank: na.rm = FALSE
## stat_identity: na.rm = FALSE
## position_identity
{% endhighlight %}



{% highlight r %}
plotly::ggplotly(g)
{% endhighlight %}



{% highlight text %}
## Auto configuration failed
## 140038393392768:error:25066067:DSO support routines:DLFCN_LOAD:could not load the shared library:dso_dlfcn.c:185:filename(libssl_conf.so): libssl_conf.so: cannot open shared object file: No such file or directory
## 140038393392768:error:25070067:DSO support routines:DSO_load:could not load the shared library:dso_lib.c:244:
## 140038393392768:error:0E07506E:configuration file routines:MODULE_LOAD_DSO:error loading dso:conf_mod.c:285:module=ssl_conf, path=ssl_conf
## 140038393392768:error:0E076071:configuration file routines:MODULE_RUN:unknown module name:conf_mod.c:222:module=ssl_conf
{% endhighlight %}



{% highlight text %}
## Error in (function (url = NULL, file = "webshot.png", vwidth = 992, vheight = 744, : webshot.js returned failure value: 1
{% endhighlight %}

So its negative correlation.

Looking at the which variables we wanna select

{% highlight r %}
majors_processed %>%
  select(Major, Total, ShareWomen, Sample_size, Median) %>%
  lm(Median ~ ShareWomen, data = ., weights = Sample_size)
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = Median ~ ShareWomen, data = ., weights = Sample_size)
## 
## Coefficients:
## (Intercept)   ShareWomen  
##       52073       -23650
{% endhighlight %}

weighted linear regression.



{% highlight r %}
majors_processed %>%
  select(Major, Total, ShareWomen, Sample_size, Median) %>%
  lm(Median ~ ShareWomen, data = ., weights = Sample_size) %>%
  summary()
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = Median ~ ShareWomen, data = ., weights = Sample_size)
## 
## Weighted Residuals:
##     Min      1Q  Median      3Q     Max 
## -260500  -61042  -13899   33262  865081 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)    52073       1436  36.255   <2e-16 ***
## ShareWomen    -23650       2403  -9.842   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 123000 on 170 degrees of freedom
##   (1 observation deleted due to missingness)
## Multiple R-squared:  0.363,	Adjusted R-squared:  0.3592 
## F-statistic: 96.87 on 1 and 170 DF,  p-value: < 2.2e-16
{% endhighlight %}
This is a weighted linear regression. Regression expect Mean rather than Median
. Because Salary data is log distributed Median will be close to Geometric Mean.

There may be negative correlation. means there will be decrease in salary upto 23000

There are lot of work to be done and more to be explore like 
unemployment and other variables etc.

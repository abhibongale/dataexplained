---
layout: post
title: "Bechdel Test"
description: "One of the most enduring tools to measure Hollywood’s gender bias is a test originally promoted by cartoonist Alison Bechdel in a 1985 strip from her “Dykes To Watch Out For” series. Bechdel said that if a movie can satisfy three criteria — there are at least two named women in the picture, they have a conversation with each other at some point, and that conversation isn’t about a male character — then it passes “The Rule,” whereby female characters are allocated a bare minimum of depth. You can see a copy of that strip here."
output: html_document
date: "2021-03-18"
category: r
tags: [r, fivethiryeight.data, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---



![bechdel-test](https://fivethirtyeight.com/wp-content/uploads/2014/04/477092007.jpg)

[Five Thirty Eight](https://fivethirtyeight.com/features/the-dollar-and-cents-case-against-hollywoods-exclusion-of-women/)



{% highlight r %}
movies <- read_csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/bechdel/movies.csv")
{% endhighlight %}

## data wrangling

{% highlight r %}
movies <- movies %>%
  mutate(across(contains("gross"), parse_number))
{% endhighlight %}




{% highlight r %}
movies %>%
  count(year, binary) %>%
  ggplot(aes(year, n, fill = binary)) +
  geom_col()
{% endhighlight %}

![center](/figs/2021-03-09-bechdel-test/unnamed-chunk-3-1.png)

{% highlight r %}
movies %>%
  group_by(decade = 10 * (year %/% 10)) %>%
  summarize(n_movies = n(),
            pct_pass = mean(binary == "PASS")) %>%
  ggplot(aes(decade, pct_pass)) +
  geom_line() +
  geom_point(aes(size = n_movies)) +
  expand_limits(y = 0)
{% endhighlight %}

![center](/figs/2021-03-09-bechdel-test/unnamed-chunk-3-2.png)

{% highlight r %}
movies %>%
  filter(year >= 1990) %>%
  arrange(desc(`intgross_2013$`)) %>%
  select(title, budget, intgross, `intgross_2013$`, binary) %>%
  head(25) %>%
  mutate(title = fct_reorder(title, `intgross_2013$`)) %>%
  ggplot(aes(`intgross_2013$`, title, fill = binary)) +
  geom_col()
{% endhighlight %}

![center](/figs/2021-03-09-bechdel-test/unnamed-chunk-3-3.png)

{% highlight r %}
movies %>%
  ggplot(aes(`intgross_2013$`, binary)) +
  geom_boxplot() +
  scale_x_log10()
{% endhighlight %}

![center](/figs/2021-03-09-bechdel-test/unnamed-chunk-3-4.png)

{% highlight r %}
movies %>%
  ggplot(aes(`intgross_2013$`, fill = binary)) +
  geom_density(alpha = 0.5) +
  scale_x_log10()
{% endhighlight %}

![center](/figs/2021-03-09-bechdel-test/unnamed-chunk-3-5.png)

{% highlight r %}
lm(log2(`intgross_2013$`) ~ binary, data = movies) %>%
  summary()
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = log2(`intgross_2013$`) ~ binary, data = movies)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -16.5767  -1.1421   0.3445   1.7178   5.6871 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 26.38883    0.08089 326.224  < 2e-16 ***
## binaryPASS  -0.51321    0.12091  -4.244  2.3e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 2.539 on 1781 degrees of freedom
##   (11 observations deleted due to missingness)
## Multiple R-squared:  0.01001,	Adjusted R-squared:  0.009458 
## F-statistic: 18.02 on 1 and 1781 DF,  p-value: 2.304e-05
{% endhighlight %}



{% highlight r %}
lm(log2(`domgross_2013$`) ~ binary, data = movies) %>%
  summary()
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = log2(`domgross_2013$`) ~ binary, data = movies)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -15.6169  -0.9034   0.5124   1.6282   5.2934 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 25.42906    0.08078 314.786  < 2e-16 ***
## binaryPASS  -0.46264    0.12082  -3.829 0.000133 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 2.531 on 1774 degrees of freedom
##   (18 observations deleted due to missingness)
## Multiple R-squared:  0.008198,	Adjusted R-squared:  0.007639 
## F-statistic: 14.66 on 1 and 1774 DF,  p-value: 0.000133
{% endhighlight %}



{% highlight r %}
movies %>%
  count(clean_test, binary) %>%
  mutate(clean_test = fct_reorder(clean_test, n)) %>%
  ggplot(aes(n, clean_test)) +
  geom_col(aes(fill = binary)) 
{% endhighlight %}

![center](/figs/2021-03-09-bechdel-test/unnamed-chunk-4-1.png)


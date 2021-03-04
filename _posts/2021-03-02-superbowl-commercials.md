---
layout: post
title: "Superbowl commercials"
description: "The data this week comes from FiveThirtyEight. They have a corresponding article on the topic. Note that the original source was superbowl-ads.com. You can watch all the ads via the FiveThirtyEight article above."
output: html_document
date: "2021-03-04"
category: r
tags: [r, tidytuesday, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---





![superbowl](https://projects.fivethirtyeight.com/super-bowl-ads/images/SUPER-BOWL-ADS-Topper.png)
[Image from fivethirtyeight](https://projects.fivethirtyeight.com/super-bowl-ads/images/SUPER-BOWL-ADS-Topper.png)

Millions of viewers who tune into the big game year after year, I wanted to know everything about them … by analyzing and categorizing, of course. I dug into the defining characteristics of a Super Bowl ad, then grouped commercials.
The data this week comes from [FiveThirtyEight](https://github.com/fivethirtyeight/superbowl-ads). 

[data-source](https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-03-02/readme.md)



{% highlight r %}
youtube <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-03-02/youtube.csv')
{% endhighlight %}


{% highlight r %}
# data wrangling
youtube <- youtube %>%
  mutate(brand = fct_recode(brand, Hyundai = "Hynudai"))
{% endhighlight %}



{% highlight r %}
# aesthetic style
my_style <-function () 
 {
     font <- "Helvetica"
     ggplot2::theme(plot.title = ggplot2::element_text(family = font, size = 14, face = "bold",
                                                       color = "#222222"), 
         plot.subtitle = ggplot2::element_text(family = font, size = 12, 
                                               margin = ggplot2::margin(9, 0, 9, 0)), 
         plot.caption = ggplot2::element_blank(), 
         legend.position = "top", legend.text.align = 0, 
         legend.background = ggplot2::element_blank(), 
         legend.title = ggplot2::element_blank(), 
         legend.key = ggplot2::element_blank(), 
         legend.text = ggplot2::element_text(family = font, size = 10, color = "#222222"), 
         axis.title = ggplot2::element_blank(), 
         axis.text = ggplot2::element_text(family = font, size = 10, color = "#222222"),
         axis.text.x = ggplot2::element_text(margin = ggplot2::margin(5, b = 10)), 
         axis.ticks = ggplot2::element_blank(), 
         axis.line = ggplot2::element_blank() 
         #panel.grid.minor = ggplot2::element_blank(), 
         #panel.grid.major.y = ggplot2::element_line(color = "#cbcbcb"), 
         #panel.grid.major.x = ggplot2::element_blank(), 
         #panel.background = ggplot2::element_blank(), 
         #strip.background = ggplot2::element_rect(fill = "white"), 
         #strip.text = ggplot2::element_text(size = 14, hjust = 0)
         )
 }
{% endhighlight %}

## Which brand has the highest Superbowl ads?

{% highlight r %}
youtube %>%
  count(brand, sort = TRUE) %>%
  head(20) %>%
  mutate(brand = fct_reorder(brand, n)) %>%
  ggplot(aes(brand, n)) +
  geom_col(fill="#1380A1") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-4-1.png)


## Superbowl ads by each brand (2000-2020)?


{% highlight r %}
youtube %>%
  ggplot(aes(year, fill = brand)) +
  geom_bar() +
  facet_wrap(~ brand) +
  geom_hline(yintercept = 0, size = 1, colour = "#333333") +
  theme(legend.position = "none") +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-5-1.png)


## count metric per view count?

{% highlight r %}
youtube %>%
  pivot_longer(like_count:comment_count, names_to = "metric") %>%
  ggplot(aes(value)) +
  geom_histogram(binwidth = 0.5, fill = "1380A1") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_x_log10(labels = scales::comma) +
  labs(x = "# of views") +
  facet_wrap(~ metric) +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-6-1.png)


## Funny and Non-Funny ads view Count of each Brand?


{% highlight r %}
youtube %>%
  filter(!is.na(view_count)) %>%
  mutate(brand = fct_reorder(brand, view_count)) %>%
  ggplot(aes(view_count, brand)) +
  geom_boxplot(aes(fill = funny)) +
  geom_vline(xintercept = 0, size = 2, colour = "#333333") +
  scale_x_log10(labels = scales::comma) +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-7-1.png)



## Median of View Count of the Superbowl ads?


{% highlight r %}
youtube %>%
  filter(!is.na(view_count)) %>%
  group_by(year) %>%
  summarise(n = n(),
            median_views = median(view_count)) %>%
  filter(n > 7) %>%
  ggplot(aes(year, median_views)) +
  geom_line(colour = "#1380A1") +
  geom_point(aes(size = n), colour = "#1380A1") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::comma) +
  theme(legend.position = "none") +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-8-1.png)

## what is the correlation between types of ads and total view count?


{% highlight r %}
youtube %>%
  filter(!is.na(view_count)) %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  group_by(category) %>%
  summarise(correlation = cor(value, log(view_count + 1))) %>%
  arrange(desc(correlation))
{% endhighlight %}



{% highlight text %}
## # A tibble: 7 x 2
##   category             correlation
##   <chr>                      <dbl>
## 1 danger                   0.107  
## 2 funny                    0.0686 
## 3 show_product_quickly     0.0348 
## 4 patriotic                0.0255 
## 5 celebrity                0.00303
## 6 animals                 -0.0295 
## 7 use_sex                 -0.0520
{% endhighlight %}

## View Count for each ads genre/category?


{% highlight r %}
youtube %>%
  filter(!is.na(view_count)) %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  group_by(category, value) %>%
  summarise(n = n(), median_view_count = median(view_count)) %>%
  ggplot(aes(category, median_view_count, fill = value)) +
  geom_col(position = "dodge") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_fill_manual(values = c("#FAAB18", "#1380A1")) +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-10-1.png)

{% highlight r %}
youtube %>%
  filter(!is.na(view_count)) %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  group_by(category) %>%
  summarise(correlation = cor(value, log(view_count + 1))) %>%
  arrange(desc(correlation))
{% endhighlight %}



{% highlight text %}
## # A tibble: 7 x 2
##   category             correlation
##   <chr>                      <dbl>
## 1 danger                   0.107  
## 2 funny                    0.0686 
## 3 show_product_quickly     0.0348 
## 4 patriotic                0.0255 
## 5 celebrity                0.00303
## 6 animals                 -0.0295 
## 7 use_sex                 -0.0520
{% endhighlight %}



{% highlight r %}
lm(log2(view_count) ~ danger + patriotic + funny + show_product_quickly
   + celebrity + animals + use_sex, data = youtube) %>%
  summary()
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = log2(view_count) ~ danger + patriotic + funny + 
##     show_product_quickly + celebrity + animals + use_sex, data = youtube)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -11.4053  -2.2006   0.1322   2.2986  12.2874 
## 
## Coefficients:
##                          Estimate Std. Error t value Pr(>|t|)    
## (Intercept)               14.0569     0.7224  19.458   <2e-16 ***
## dangerTRUE                 0.9167     0.6030   1.520    0.130    
## patrioticTRUE              0.7831     0.7704   1.016    0.310    
## funnyTRUE                  0.7292     0.6569   1.110    0.268    
## show_product_quicklyTRUE   0.3205     0.5838   0.549    0.584    
## celebrityTRUE              0.1328     0.5933   0.224    0.823    
## animalsTRUE               -0.4333     0.5669  -0.764    0.445    
## use_sexTRUE               -0.6258     0.6349  -0.986    0.325    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 4.02 on 223 degrees of freedom
##   (16 observations deleted due to missingness)
## Multiple R-squared:  0.02545,	Adjusted R-squared:  -0.005137 
## F-statistic: 0.8321 on 7 and 223 DF,  p-value: 0.5616
{% endhighlight %}


## Superbowl ads genre/category trend?

{% highlight r %}
youtube %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  group_by(category, year = 2 * (year %/% 2)) %>%
  summarise(percent = mean(value),
            n = n()) %>%
  ggplot(aes(year, percent, color = category)) +
  geom_line() +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::percent) +
  facet_wrap(~ category) +
  theme(legend.position = "none") +
  labs(x = "2-year period", 
       y = "% of ads with this quality") +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-11-1.png)


## Modelling the genre/category 


{% highlight r %}
glm(animals ~ year, 
    data = youtube, 
    family = "binomial") %>%
 summary()
{% endhighlight %}



{% highlight text %}
## 
## Call:
## glm(formula = animals ~ year, family = "binomial", data = youtube)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -0.9682  -0.9659  -0.9636   1.4045   1.4089  
## 
## Coefficients:
##               Estimate Std. Error z value Pr(>|z|)
## (Intercept) -2.0421594 45.2334161  -0.045    0.964
## year         0.0007564  0.0225019   0.034    0.973
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 326.17  on 246  degrees of freedom
## Residual deviance: 326.17  on 245  degrees of freedom
## AIC: 330.17
## 
## Number of Fisher Scoring iterations: 4
{% endhighlight %}



{% highlight r %}
model <- youtube %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  group_by(category) %>%
  summarize(model = list(glm(value ~ year, family = "binomial"))) %>%
  mutate(td = map(model, broom::tidy)) %>%
  unnest(td) %>%
  filter(term != "(Intercept)") %>%
  arrange(desc(estimate))
{% endhighlight %}



{% highlight r %}
youtube %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  group_by(category, 
           year = 2 * (year %/% 2)) %>%
  summarize(percnt = mean(value),
            n = n()) %>%
  inner_join(model, by = "category") %>%
  mutate(category = str_to_title(str_replace_all(category, "_", " "))) %>%
  filter(p.value <= .05) %>%
  ggplot(aes(year, percnt, colour = category)) +
  geom_line() +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::percent) +
  facet_wrap(~ category) +
  theme(legend.position = "none") +
  my_style() +
  labs(x = "Time(rounded to 2-years)",
       y = "% of ads with this quality")
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-13-1.png)


## Brand's preferred genre/category?


{% highlight r %}
library(tidytext)

youtube %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  group_by(brand, category) %>%
  mutate(category = str_to_title(str_replace_all(category, "_", " "))) %>%
  summarise(percnt = mean(value)) %>%
  ungroup() %>%
  mutate(category = reorder_within(category, percnt, brand)) %>%
  ggplot(aes(percnt, category)) +
  geom_col(fill = "#1380A1") +
  geom_vline(xintercept = 0, size = 1, colour = "#333333") +
  scale_y_reordered() +
  scale_x_continuous(labels = scales::percent) +
  facet_wrap(~ brand, scales = "free_y") +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-14-1.png)



{% highlight r %}
youtube %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  group_by(brand, category) %>%
  mutate(category = str_to_title(str_replace_all(category, "_", " "))) %>%
  summarise(percnt = mean(value)) %>%
  ggplot(aes(category, brand, fill = percnt)) +
  geom_tile() +
  scale_fill_gradient2(low = "#FAAB18", high = "#990000", midpoint = 0.5) +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-15-1.png)



{% highlight r %}
youtube %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  group_by(brand, category) %>%
  mutate(category = str_to_title(str_replace_all(category, "_", " "))) %>%
  summarise(percnt = mean(value)) %>%
  reshape2::acast(brand ~ category, value.var = "percnt") %>%
  heatmap()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-16-1.png)

## What is the like_dislike ratio with genre/category?


{% highlight r %}
youtube %>%
  pivot_longer(funny:use_sex, names_to = "category") %>%
  mutate(like_ratio = like_count/(like_count + dislike_count)) %>%
  filter(!is.na(like_ratio), !is.infinite(like_ratio)) %>%
  group_by(brand, category, view_count) %>%
  summarise(like_ratio) %>%
  arrange(desc(like_ratio)) %>%
  ggplot(aes(view_count, like_ratio)) +
  geom_point(aes(colour = brand)) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  geom_text(aes(label = category), check_overlap = TRUE, vjust = 1) +
  scale_x_log10(labels = scales::comma) +
  my_style()
{% endhighlight %}

![center](/figs/2021-03-02-superbowl-commercials/unnamed-chunk-17-1.png)


## Reference:

1. [Super Bowl Ads](https://github.com/fivethirtyeight/superbowl-ads)
2. [David Robinson](https://www.youtube.com/watch?v=EHqFDXa-sH4)

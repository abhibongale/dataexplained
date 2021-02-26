---
layout: post
title: "Employement and Demographics"
description: "Attempt to learn and apply k-means clustering on tidytuesday dataset to gain insight. #DuboisChallenge"
output: html_document
date: "2021-02-26"
category: r
tags: [r, tidytuesday, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---





## Read dataset


{% highlight r %}
employed <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-23/employed.csv')
{% endhighlight %}


## Data Wrangling


{% highlight r %}
employed_tidy <- employed %>%
  filter(!is.na(employ_n)) %>%
  group_by(occupation = paste(industry, minor_occupation),
           race_gender) %>%
  summarise(n = mean(employ_n)) %>%
  ungroup()
{% endhighlight %}



{% highlight r %}
employment_demo <- employed_tidy %>%
  filter(race_gender %in% c("Women", "Black or African American", "Asian")) %>%
  pivot_wider(names_from = race_gender, values_from = n, values_fill = 0) %>%
  janitor::clean_names() %>%
  left_join(employed_tidy %>%
              filter(race_gender == "TOTAL") %>%
              select(-race_gender) %>%
              rename(total = n)) %>%
  # reduce the size of the dataset
  filter(total > 1e4) %>%
  # Across Apply a function (or functions) across multiple columns, function  variables (.) divided by total
  # we have to take log because total is in millions and broad range and k-means are sensitive how numbers are scale. So we have to scale with scale function
  mutate(across(c(asian, black_or_african_american, women), ~ .  / total), 
         total = log(total),
         across(is.numeric, ~as.numeric(scale(.)))
         ) %>%
  mutate(occupation = snakecase::to_snake_case(occupation))

employment_demo
{% endhighlight %}



{% highlight text %}
## # A tibble: 211 x 5
##    occupation                  asian black_or_african_…    women  total
##    <chr>                       <dbl>              <dbl>    <dbl>  <dbl>
##  1 agriculture_and_related_c… -0.625            -0.501  -1.33    -1.98 
##  2 agriculture_and_related_f… -1.05             -1.38   -0.515    0.630
##  3 agriculture_and_related_i… -0.999            -1.44   -1.41    -1.39 
##  4 agriculture_and_related_m… -1.17             -1.87   -0.293    0.662
##  5 agriculture_and_related_m… -1.17             -1.85   -0.302    0.682
##  6 agriculture_and_related_o… -0.753            -1.73    2.28    -0.811
##  7 agriculture_and_related_p… -0.444            -0.0947 -0.631   -1.34 
##  8 agriculture_and_related_p… -0.421            -1.33    0.00826 -1.14 
##  9 agriculture_and_related_p… -1.48             -0.758  -0.846   -1.87 
## 10 agriculture_and_related_s… -1.48             -1.62    0.437   -1.83 
## # … with 201 more rows
{% endhighlight %}


## Implement k-means clustering


{% highlight r %}
employment_clust <- kmeans(select(employment_demo, -occupation), centers = 3)
summary(employment_clust)
{% endhighlight %}



{% highlight text %}
##              Length Class  Mode   
## cluster      211    -none- numeric
## centers       12    -none- numeric
## totss          1    -none- numeric
## withinss       3    -none- numeric
## tot.withinss   1    -none- numeric
## betweenss      1    -none- numeric
## size           3    -none- numeric
## iter           1    -none- numeric
## ifault         1    -none- numeric
{% endhighlight %}


{% highlight r %}
broom::tidy(employment_clust)
{% endhighlight %}



{% highlight text %}
## # A tibble: 3 x 7
##     asian black_or_african_americ…  women  total  size withinss cluster
##     <dbl>                    <dbl>  <dbl>  <dbl> <int>    <dbl> <fct>  
## 1  1.32                     -0.556  0.333  0.860    47     102. 1      
## 2 -0.0407                    0.738  0.716  0.184    80     202. 2      
## 3 -0.699                    -0.392 -0.869 -0.657    84     159. 3
{% endhighlight %}



{% highlight r %}
broom::augment(employment_clust, employment_demo) %>%
  ggplot(aes(total, black_or_african_american, color = .cluster)) +
  geom_point(alpha = 0.8)
{% endhighlight %}

![center](/figs/2021-02-26-employment-and-demographics/unnamed-chunk-6-1.png)

there is no clean separation with 3 clusters we have to choose best number of clusters

## choosing k


{% highlight r %}
library(broom)
kclusts <- tibble(k = 1:9) %>%
  mutate(
    kclust = map(k, ~kmeans(select(employment_demo, -occupation), .x)),
    tidied = map(kclust, broom::tidy),
    glanced = map(kclust, broom::glance),
    augmented = map(kclust, broom::augment, employment_demo)
  )

kclusts %>%
  unnest(glanced) %>%
  ggplot(aes(k, tot.withinss)) +
  geom_line(alpha = 0.8) +
  geom_point(size = 2)
{% endhighlight %}

![center](/figs/2021-02-26-employment-and-demographics/unnamed-chunk-7-1.png)



{% highlight r %}
library(plotly)

employment_clust <- kmeans(select(employment_demo, -occupation), centers = 5)

p <- broom::augment(employment_clust, employment_demo) %>%
  ggplot( aes(total, black_or_african_american, color = .cluster,
             name = occupation)) +
  geom_point(alpha = 0.8)

ggplotly(p)
{% endhighlight %}



{% highlight text %}
## Error in loadNamespace(name): there is no package called 'webshot'
{% endhighlight %}

## Refernce

[Julia Silge](https://juliasilge.com/blog/kmeans-employment/)

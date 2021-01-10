---
layout: post
title: "Which Construction cost more per km Railways or Metros?"
description: "Here I analyze top 8 conuntries from  transit-cost-project data to get the datainsight. dataset was publish by r4ds community as a part of tidytuesday challenge"
output: html_document
date: "2021-01-10"
category: r
tags: [r, kaggle, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---


**Dataset information**:  We investigate this question across hundreds of transit projects from around the world. 
We have created a database that spans more than 50 countries and totals more than 11,000 km of urban rail built since the late 1990s. 
We will also examine this question in greater detail by carrying out six in-depth case studies that take a closer look at unique considerations and variables that aren’t easily quantified, like project management, governance, and site conditions.






## 1. Read the data


{% highlight r %}
# read the data
transit_cost <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-01-05/transit_cost.csv')

dim(transit_cost) # dimension of data
{% endhighlight %}



{% highlight text %}
## [1] 544  20
{% endhighlight %}



## 2. Data Wrangling

The country column we have country code instead of country name.
while start_year, end_year and real_cost are character rather than numeric.


{% highlight r %}
transit_cost <- transit_cost %>%
  # remove 'NA' rows
  filter(!is.na(e)) %>% 
  # into numeric
  mutate_at(vars(start_year, end_year, real_cost), as.numeric) %>% 
  mutate(country_code = ifelse(country == "UK", "GB", country),
         country = countrycode(country_code, "iso2c","country.name")) 
{% endhighlight %}

## 3. Explorartory Analysis

### Transit Projects in United States? And its Total Costs?


{% highlight r %}
transit_cost %>%
  filter(country == "United States") %>%
  select(-c(source1, source2)) %>%
  mutate(line = fct_reorder(line, start_year)) %>%
  ggplot(aes(xmin = start_year, xmax = end_year, y = line, 
             colour = city)) +
  geom_errorbarh(height = 0.1, size = 1.5) +
  geom_text(aes(label = glue::glue("{real_cost} MM"), 
                x = end_year), vjust = -0.2, hjust = 0.5, colour = "black") +
  scale_colour_viridis_d(direction = -1) +
  labs(x = "Years",
       y = "") +
  theme(legend.position = "top")
{% endhighlight %}

![center](/figs/2021-01-05-transit-cost-project/unnamed-chunk-3-1.png)

In united States, NewYork has most transit projects.

###  Top 8 Countries with highest cost (Millions in USD) per km? which type of 
construction cost more?



{% highlight r %}
transit_cost %>%
  filter(!is.na(cost_km_millions),
         !is.na(rr)) %>%
  mutate(country = fct_lump(country, 8)) %>%
  add_count(country, name = "count") %>%
  mutate(country = glue::glue("{country} ({count})"),
         country = fct_reorder(country, cost_km_millions),
         rr = ifelse(rr == 1, "Railway", "Not Railway")) %>%
  ggplot(aes(country, cost_km_millions)) +
  geom_boxplot(aes(fill = rr)) +
  geom_jitter(alpha = 0.05) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::dollar) +
  coord_flip() +
  labs(y = "cost per km",
       fill = "") +
  theme(legend.position = "top",
        legend.direction="horizontal")
{% endhighlight %}

![center](/figs/2021-01-05-transit-cost-project/unnamed-chunk-4-1.png)


Its clear, Railway cost more than Not Railway category. The Not Railway category (mostly metros).





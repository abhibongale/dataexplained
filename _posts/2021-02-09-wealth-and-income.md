---
layout: post
title: "Wealth and income over time"
description: "Why hasn’t wealth inequality improved over the past 50 years? And why, in particular, has the racial wealth gap not closed? These nine charts illustrate how income inequality, earnings gaps, homeownership rates, retirement savings, student loan debt have contributed to these growing wealth disparities."
output: html_document
date: "2021-02-12"
category: r
tags: [r, tidytuesday, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---




{% highlight r %}
library(tidyverse) # metadata of packages
theme_set(theme_light())
{% endhighlight %}



{% highlight r %}
lifetime_earn <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/lifetime_earn.csv')
student_debt <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/student_debt.csv')
retirement <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/retirement.csv')
home_owner <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/home_owner.csv')
race_wealth <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/race_wealth.csv')
income_time <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/income_time.csv')
income_limits <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/income_limits.csv')
income_aggregate <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/income_aggregate.csv')
income_distribution <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/income_distribution.csv')
income_mean <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-02-09/income_mean.csv')
{% endhighlight %}

# Introduction

![Image](https://images.pexels.com/photos/220365/pexels-photo-220365.jpeg)
[Photo by Pixabay from Pexels](https://www.pexels.com/photo/adult-beanie-crisis-despair-220365/)

Why hasn’t wealth inequality improved over the past 50 years? And why, in particular, has the racial wealth gap not closed? These nine charts illustrate how income inequality, earnings gaps, homeownership rates, retirement savings, student loan debt, and lopsided asset-building subsidies have contributed to these growing wealth disparities.


{% highlight r %}
asthetatic_look <-function () 
 {
     font <- "Helvetica"
     ggplot2::theme(plot.title = ggplot2::element_text(family = font, size = 20, face = "bold",
                                                       color = "#222222"), 
         plot.subtitle = ggplot2::element_text(family = font, size = 16, 
                                               margin = ggplot2::margin(9, 0, 9, 0)), 
         plot.caption = ggplot2::element_blank(), 
         legend.position = "top", legend.text.align = 0, 
         legend.background = ggplot2::element_blank(), 
         legend.title = ggplot2::element_blank(), 
         legend.key = ggplot2::element_blank(), 
         legend.text = ggplot2::element_text(family = font, size = 14, color = "#222222"), 
         axis.title = ggplot2::element_blank(), 
         axis.text = ggplot2::element_text(family = font, size = 14, color = "#222222"),
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

## Black and Hispanic families lag behind on major wealth-building measures, like homeownership


{% highlight r %}
#Prepare data 
home_owner %>%
  mutate(race = factor(race)) %>%
  #Make plot
  ggplot(aes(year, home_owner_pct)) +
  geom_line(aes(colour = race), size = 1) +
  geom_point(aes(colour = race)) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_colour_manual(values = c("#FAAB18", "#1380A1", "#990000")) +
  asthetatic_look()
{% endhighlight %}

![center](/figs/2021-02-09-wealth-and-income/unnamed-chunk-4-1.png)

##  One reason for rising wealth inequality is income inequality

Share of aggregate income received by each fifth and top 5% of each racial group/household.


{% highlight r %}
income_aggregate %>%
  ggplot(aes(year, income_share)) +
  geom_line(aes(colour = income_quintile)) +
  facet_wrap(~race, scales = "free") +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  asthetatic_look()
{% endhighlight %}

![center](/figs/2021-02-09-wealth-and-income/unnamed-chunk-5-1.png)

{% highlight r %}
  #scale_fill_discrete(breaks=c("Top 5%","Highest","Fourth", "Third", "Second", "Lowest"))
{% endhighlight %}



{% highlight r %}
income_distribution %>%
  filter(race == "Black Alone" | race == "White Alone") %>%
  ggplot(aes(year, income_median)) +
  geom_col(aes(fill = race), position = "dodge") +
  scale_fill_manual(values = c("#FAAB18", "#1380A1")) +
  scale_y_continuous(labels = scales::dollar_format()) +
  asthetatic_look()
{% endhighlight %}

![center](/figs/2021-02-09-wealth-and-income/unnamed-chunk-6-1.png)


## Differences in earnings add up over a lifetime and widen the racial and ethnic wealth gap


{% highlight r %}
lifetime_earn %>%
  ggplot(aes(gender, lifetime_earn)) +
  geom_col(aes(fill = race), position = "dodge") +
  scale_fill_manual(values = c("#FAAB18", "#1380A1", "#990000")) +
  scale_y_continuous(labels = scales::dollar_format()) +
  asthetatic_look()
{% endhighlight %}

![center](/figs/2021-02-09-wealth-and-income/unnamed-chunk-7-1.png)


## Black families carry more student loan debt than white families


{% highlight r %}
#Prepare data 
student_debt %>%
  #Make plot
  ggplot(aes(year, loan_debt_pct)) +
  geom_line(aes(colour = race), size = 1) +
  geom_point(aes(colour = race)) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::percent_format(scale = 100)) +
  scale_colour_manual(values = c("#FAAB18", "#1380A1", "#990000")) +
  labs(subtitle = "Student Dept 1976-2016*, %") +
  asthetatic_look()
{% endhighlight %}

![center](/figs/2021-02-09-wealth-and-income/unnamed-chunk-8-1.png)

## Black and Hispanic families have less in liquid retirement savings


{% highlight r %}
#Prepare data 
retirement %>%
  #Make plot
  ggplot(aes(year, retirement)) +
  geom_line(aes(colour = race), size = 1) +
  geom_point(aes(colour = race)) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::dollar_format()) +
  scale_colour_manual(values = c("#FAAB18", "#1380A1", "#990000")) +
  labs(subtitle = "Retirement") +
  asthetatic_look()
{% endhighlight %}

![center](/figs/2021-02-09-wealth-and-income/unnamed-chunk-9-1.png)

## Racial and ethnic wealth disparities persist


{% highlight r %}
race_wealth %>%
  filter(!is.na(wealth_family), race != "Non-White", type == "Median") %>%
  ggplot(aes(year, wealth_family)) +
  geom_line(aes(colour = race), size = 0.8) +
  geom_point(aes(colour = race)) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_colour_manual(values = c("#FAAB18", "#1380A1", "#990000")) +
  asthetatic_look()
{% endhighlight %}

![center](/figs/2021-02-09-wealth-and-income/unnamed-chunk-10-1.png)

## Black families carry more student loan debt than white families


{% highlight r %}
student_debt %>%
  ggplot(aes(year, loan_debt_pct)) +
  geom_line(aes(colour = race)) +
  geom_point(aes(colour = race)) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_colour_manual(values = c("#FAAB18", "#1380A1", "#990000")) +
  asthetatic_look()
{% endhighlight %}

![center](/figs/2021-02-09-wealth-and-income/unnamed-chunk-11-1.png)

## Black and Hispanic families have less in liquid retirement savings


{% highlight r %}
retirement %>%
  ggplot(aes(year, retirement)) +
  geom_line(aes(colour = race)) +
  geom_point(aes(colour = race)) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::dollar_format()) +
  scale_colour_manual(values = c("#FAAB18", "#1380A1", "#990000")) +
  asthetatic_look()
{% endhighlight %}

![center](/figs/2021-02-09-wealth-and-income/unnamed-chunk-12-1.png)


## Reference
- [wealth-inequality-charts](https://apps.urban.org/features/wealth-inequality-charts/)

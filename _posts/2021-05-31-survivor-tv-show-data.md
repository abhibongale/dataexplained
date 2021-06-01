---
layout: post
title: "Survivor TV Show data"
description: "data sets detailing events across all 40 seasons of the US Survivor, including castaway information, vote history, immunity and reward challenge winners and jury votes."
output: html_document
date: "2021-06-01"
category: r
tags: [r, tidytuesday, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---

![survivoR](http://gradientdescending.com/wp-content/uploads/2020/11/hex-torch.png)





{% highlight r %}
summary_raw <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-06-01/summary.csv')
{% endhighlight %}



{% highlight text %}
## 
## ── Column specification ──────────────────────────────────────────────────────────────
## cols(
##   season_name = col_character(),
##   season = col_double(),
##   location = col_character(),
##   country = col_character(),
##   tribe_setup = col_character(),
##   full_name = col_character(),
##   winner = col_character(),
##   runner_ups = col_character(),
##   final_vote = col_character(),
##   timeslot = col_character(),
##   premiered = col_date(format = ""),
##   ended = col_date(format = ""),
##   filming_started = col_date(format = ""),
##   filming_ended = col_date(format = ""),
##   viewers_premier = col_double(),
##   viewers_finale = col_double(),
##   viewers_reunion = col_double(),
##   viewers_mean = col_double(),
##   rank = col_double()
## )
{% endhighlight %}


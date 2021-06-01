---
layout: post
title: "CEO Departures"
description: ""
output: html_document
date: "2021-06-01"
category: r
tags: [r, tidytuesday, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---





{% highlight r %}
departures <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-04-27/departures.csv')
{% endhighlight %}



{% highlight text %}
## 
## ── Column specification ──────────────────────────────────────────────────────────────
## cols(
##   dismissal_dataset_id = col_double(),
##   coname = col_character(),
##   gvkey = col_double(),
##   fyear = col_double(),
##   co_per_rol = col_double(),
##   exec_fullname = col_character(),
##   departure_code = col_double(),
##   ceo_dismissal = col_double(),
##   interim_coceo = col_character(),
##   tenure_no_ceodb = col_double(),
##   max_tenure_ceodb = col_double(),
##   fyear_gone = col_double(),
##   leftofc = col_datetime(format = ""),
##   still_there = col_character(),
##   notes = col_character(),
##   sources = col_character(),
##   eight_ks = col_character(),
##   cik = col_double(),
##   `_merge` = col_character()
## )
{% endhighlight %}

We will predict the departure of ceo's due to health issues or not in this article. 

We will analyise data before making pipeline for prediction.

# Analysis dataset

`ceo_dismissal` variable will be our y (to predict value). We will look whether it contains any NA or any nonsense values.


Total non_health_dismissal and health related dismissal are ?

{% highlight r %}
departures <- departures %>%
  group_by(coname) %>%
  mutate(total_dismiss = n(), 
         ratio_dismissal = ceo_dismissal/total_dismiss) %>%
  ungroup()

departures %>%
  filter(!is.na(ceo_dismissal)) %>%
  select(coname, ceo_dismissal, ratio_dismissal) %>%
  group_by(coname) %>%
  summarise(non_health_dismiss = sum(ratio_dismissal*100)) %>%
  group_by(non_health_dismiss) %>%
  count() %>%
  arrange(desc(non_health_dismiss)) %>%
  ggplot() +
  geom_bar(aes("", n, fill = non_health_dismiss), stat="identity") +
  coord_polar(theta = "y", start = 0)
{% endhighlight %}

![center](/figs/2021-04-27-ceo-departure/unnamed-chunk-3-1.png)


{% highlight r %}
departures %>%
  count(ceo_dismissal) %>%
  summarise(total = sum(n), ratio = n/total*100)
{% endhighlight %}



{% highlight text %}
## # A tibble: 3 x 2
##   total ratio
##   <int> <dbl>
## 1  9423  65.0
## 2  9423  15.8
## 3  9423  19.2
{% endhighlight %}



{% highlight r %}
departures %>%
  filter(!is.na(ceo_dismissal)) %>%
  select(coname, ceo_dismissal, ratio_dismissal) %>%
  group_by(coname) %>%
  summarise(non_health_dismiss = sum(ratio_dismissal*100)) %>%
  group_by(non_health_dismiss) %>%
  count() %>%
  arrange(desc(non_health_dismiss)) %>%
  ggplot(aes(non_health_dismiss, n)) +
  geom_area()
{% endhighlight %}

![center](/figs/2021-04-27-ceo-departure/unnamed-chunk-5-1.png)

since, y(ceo_dismissal) variable which predicts 0 (health related) or 1 (non-health related) dismiss is positive skewed. 


{% highlight r %}
library(tidytext)
{% endhighlight %}



{% highlight text %}
## Error in library(tidytext): there is no package called 'tidytext'
{% endhighlight %}



{% highlight r %}
library(wordcloud)
{% endhighlight %}



{% highlight text %}
## Error in library(wordcloud): there is no package called 'wordcloud'
{% endhighlight %}



{% highlight r %}
departures %>%
  select(notes, ratio_dismissal) %>%
  unnest_tokens(word, notes) %>%
  anti_join(stop_words, by = "word") %>%
  count(word) %>%
  arrange(desc(n)) %>%
  filter(n > 100) %>%
  with(wordcloud(word, n, max.words = 200))
{% endhighlight %}



{% highlight text %}
## Error in unnest_tokens(., word, notes): could not find function "unnest_tokens"
{% endhighlight %}



{% highlight r %}
library(textdata)
{% endhighlight %}



{% highlight text %}
## Error in library(textdata): there is no package called 'textdata'
{% endhighlight %}



{% highlight r %}
notes_sentiment <- departures %>%
  select(notes, departure_code, exec_fullname) %>%
  unnest_tokens(word, notes) %>%
  anti_join(stop_words, by = "word") %>%
  inner_join(get_sentiments("afinn")) %>%
  group_by(departure_code, exec_fullname)%>%
  summarise(senti_value = sum(value))
{% endhighlight %}



{% highlight text %}
## Error in unnest_tokens(., word, notes): could not find function "unnest_tokens"
{% endhighlight %}



{% highlight r %}
notes_sentiment %>%
  group_by(departure_code) %>%
  summarise(sentiment_code = sum(senti_value)) %>%
  filter(!is.na(departure_code)) %>%
  ggplot(aes(departure_code, sentiment_code)) +
  geom_col()
{% endhighlight %}



{% highlight text %}
## Error in group_by(., departure_code): object 'notes_sentiment' not found
{% endhighlight %}




{% highlight r %}
library(smotefamily)
{% endhighlight %}



{% highlight text %}
## Error in library(smotefamily): there is no package called 'smotefamily'
{% endhighlight %}



{% highlight r %}
smote_departures <- departures %>%
  inner_join(notes_sentiment, by = c("exec_fullname","departure_code")) %>%
  select(fyear, departure_code, ceo_dismissal, tenure_no_ceodb, max_tenure_ceodb, total_dismiss, ratio_dismissal, senti_value) %>%
  filter(!is.na(ceo_dismissal))
{% endhighlight %}



{% highlight text %}
## Error in is.data.frame(y): object 'notes_sentiment' not found
{% endhighlight %}



{% highlight r %}
new_departure <- SMOTE(smote_departures, smote_departures$ceo_dismissal, K = 10)
{% endhighlight %}



{% highlight text %}
## Error in SMOTE(smote_departures, smote_departures$ceo_dismissal, K = 10): could not find function "SMOTE"
{% endhighlight %}



{% highlight r %}
new_departure$data %>%
  count(ceo_dismissal)
{% endhighlight %}



{% highlight text %}
## Error in count(., ceo_dismissal): object 'new_departure' not found
{% endhighlight %}


{% highlight r %}
new_departure$syn_data %>%
  count(ceo_dismissal)
{% endhighlight %}



{% highlight text %}
## Error in count(., ceo_dismissal): object 'new_departure' not found
{% endhighlight %}


{% highlight r %}
new_dataset <- new_departure$data 
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): object 'new_departure' not found
{% endhighlight %}



{% highlight r %}
library(lubridate)
{% endhighlight %}



{% highlight text %}
## 
## Attaching package: 'lubridate'
{% endhighlight %}



{% highlight text %}
## The following objects are masked from 'package:base':
## 
##     date, intersect, setdiff, union
{% endhighlight %}



{% highlight r %}
new_dataset <- new_dataset %>%
  mutate(fyear = as.Date(as.character(fyear), format = "%Y"), 
         fyear = year(fyear), ceo_dismissal = factor(ceo_dismissal))
{% endhighlight %}



{% highlight text %}
## Error in mutate(., fyear = as.Date(as.character(fyear), format = "%Y"), : object 'new_dataset' not found
{% endhighlight %}



{% highlight r %}
new_dataset %>%
  filter(fyear < 2019) %>%
  count(fyear, ceo_dismissal) %>%
  ggplot(aes(fyear, n)) +
  geom_line(aes(color = ceo_dismissal)) +
  geom_point() +
  geom_smooth()
{% endhighlight %}



{% highlight text %}
## Error in filter(., fyear < 2019): object 'new_dataset' not found
{% endhighlight %}


{% highlight r %}
departures %>%
  filter(fyear < 2019) %>%
  mutate(ceo_dismissal = factor(ceo_dismissal)) %>%
  filter(!is.na(ceo_dismissal)) %>%
  count(fyear, ceo_dismissal) %>%
  ggplot(aes(fyear, n)) +
  geom_line(aes(color = ceo_dismissal)) +
  geom_point() +
  geom_smooth()
{% endhighlight %}



{% highlight text %}
## `geom_smooth()` using method = 'loess' and formula 'y ~ x'
{% endhighlight %}

![center](/figs/2021-04-27-ceo-departure/unnamed-chunk-13-1.png)





{% highlight r %}
glm.fit = glm(ceo_dismissal ~ departure_code+senti_value, data = new_dataset, family = binomial)
{% endhighlight %}



{% highlight text %}
## Error in is.data.frame(data): object 'new_dataset' not found
{% endhighlight %}



{% highlight r %}
summary(glm.fit)
{% endhighlight %}



{% highlight text %}
## Error in object[[i]]: object of type 'closure' is not subsettable
{% endhighlight %}


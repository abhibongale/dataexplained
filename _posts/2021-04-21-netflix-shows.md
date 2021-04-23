---
layout: post
title: "Netflix Shows"
description: "This dataset consists of tv shows and movies available on Netflix as of 2019. The dataset is collected from Flixable which is a third-party Netflix search engine."
output: html_document
date: "2021-04-23"
category: r
tags: [r, tidytuesday, tidyverse, kaggle]
comments: true
editor_options: 
  chunk_output_type: console
---







{% highlight r %}
netflix_titles <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-04-20/netflix_titles.csv')
{% endhighlight %}

## 1.Data Wrangling

{% highlight r %}
netflix_titles <- netflix_titles %>%
  separate(duration, c("duration", "duration_units"), 
           sep = " ", convert = TRUE) %>%
  mutate(date_added = mdy(date_added),
         year_added = year(date_added))
{% endhighlight %}


{% highlight r %}
summarize_titles <- function(tbl) {
  tbl <- tbl %>%
    summarise(n = n(),  median_duration = median(duration),
            median_year = median(year)) %>%
  arrange(desc(n))
}
{% endhighlight %}



{% highlight r %}
netflix_titles %>%
  ggplot(aes(release_year, fill = type)) +
  geom_histogram(bindwith = 5) +
  facet_wrap(~ type, ncol = 1, scales = "free_y") 
{% endhighlight %}

![center](/figs/2021-04-21-netflix-shows/unnamed-chunk-4-1.png)


{% highlight r %}
netflix_titles %>%
  filter(type == "Movie") %>%
  mutate(decade = 10 * (release_year %/% 10)) %>%
  ggplot(aes(decade, duration, group = decade)) +
  geom_boxplot()
{% endhighlight %}

![center](/figs/2021-04-21-netflix-shows/unnamed-chunk-5-1.png)


{% highlight r %}
netflix_titles %>%
  separate_rows(listed_in, sep = ", ") %>%
  group_by(type, genre = listed_in) %>%
  summarise(n = n(),  median_duration = median(duration)) %>%
  arrange(desc(n)) %>%
  filter(type == "Movie", genre != "Movies") %>%
  mutate(genre = fct_reorder(genre, median_duration)) %>%
  ggplot(aes(median_duration, genre)) +
  geom_col()
{% endhighlight %}

![center](/figs/2021-04-21-netflix-shows/unnamed-chunk-6-1.png)


## Date Added


{% highlight r %}
netflix_titles %>%
  filter(!is.na(date_added), !is.na(rating), year_added >= 2015) %>%
  group_by(type) %>%
  mutate(rating = fct_lump(rating, 4)) %>%
  count(type, year_added, rating) %>%
  group_by(type, year_added) %>%
  mutate(percent = n / sum(n)) %>%
  ggplot(aes(year_added, percent, fill = rating)) +
  geom_area() +
  facet_wrap(~ type)
{% endhighlight %}

![center](/figs/2021-04-21-netflix-shows/unnamed-chunk-7-1.png)



{% highlight r %}
netflix_titles %>%
  filter(!is.na(type), !is.na(country)) %>%
  count(country =fct_lump(country, 8), type, sort = TRUE) %>%
  mutate(country = fct_reorder(country, n)) %>%
  ggplot(aes(n, country, fill = type)) +
  geom_col()
{% endhighlight %}

![center](/figs/2021-04-21-netflix-shows/unnamed-chunk-8-1.png)


{% highlight r %}
netflix_titles %>%
  filter(!is.na(country), type == "Movie") %>%
  group_by(country = fct_lump(country, 8)) %>%
  summarise(duration = mean(duration)) %>%
  mutate(country = fct_reorder(country, duration)) %>%
  ggplot(aes(country, duration)) +
  geom_col()
{% endhighlight %}

![center](/figs/2021-04-21-netflix-shows/unnamed-chunk-9-1.png)



{% highlight r %}
library(tidytext)
library(snakecase)
netflix_titles %>% 
  unnest_tokens(word, description) %>%
  anti_join(stop_words, by = "word") %>%
  count(type, word, sort = TRUE) %>%
  mutate(type = to_snake_case(type)) %>%
  spread(type, n, fill = 0) %>%
  mutate(total = movie + tv_show) %>%
  arrange(desc(total)) %>%
  head(100) %>%
  ggplot(aes(movie, tv_show)) +
  geom_point() +
  geom_text(aes(label = word), vjust = 1, hjust = 1) +
  scale_x_log10() +
  scale_y_log10()
{% endhighlight %}

![center](/figs/2021-04-21-netflix-shows/unnamed-chunk-10-1.png)





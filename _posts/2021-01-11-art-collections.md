---
layout: post
title: "Art Collections"
description: ""
output: html_document
date: "2021-01-23"
category: r
tags: [r, tidytuesday, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---


**DataSet Information** Here we present the metadata for around 70,000 artworks that Tate owns or jointly owns with the National Galleries of Scotland as part of ARTIST ROOMS. Metadata for around 3,500 associated artists is also included.

    The metadata here is released under the Creative Commons Public Domain CC0 licence. Images are not included and are not part of the dataset. Use of Tate images is covered on the Copyright and permissions page. You may also license images for commercial use.

    Tate requests that you actively acknowledge and give attribution to Tate wherever possible. Attribution supports future efforts to release other data. It also reduces the amount of ‘orphaned data’, helping retain links to authoritative sources.

    Here are some examples of Tate data usage in the wild. Please submit a pull request with your creation added to this list.




## Explore the data


{% highlight r %}
# read the data
artwork <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-01-12/artwork.csv')
artists <- readr::read_csv("https://github.com/tategallery/collection/raw/master/artist_data.csv")
{% endhighlight %}

## Data Wrangling


{% highlight r %}
artwork <- artwork %>%
  # remove unwanted column
  select(-c("accession_number", "artistRole", "artistId", "dateText", "creditLine", "units", "inscription", "thumbnailCopyright", "thumbnailUrl", "url"))
{% endhighlight %}


## Year of creation & Acquisition Year


{% highlight r %}
artwork %>%
  filter(!is.na(year) | !is.na(acquisitionYear)) %>%
  # make a plot
  ggplot() +
  # histogram
  geom_histogram(aes(year, fill = "#1380A1"), 
                 bins = 50, alpha = 0.7) +
  geom_histogram(aes(acquisitionYear, fill = "#FAAB18"), 
                 bins = 50, alpha = 0.7) +
  geom_hline(aes(yintercept = 0), size = 0.5, colour="#333333") +
  scale_fill_manual(values = c("#1380A1", "#FAAB18"), 
                    labels = c("Year of creation", "Year acquired")) +
  # Labels
  labs(fill = "", y = "Count", x = "Year") +
  # theme 
  theme(legend.position = "top", 
        legend.text = element_text(family = "Helvetica", size = 14),
        axis.text = element_text(family = "Helvetica", size = 14),
        axis.title = element_text(family = "Helvetica", size = 14))
{% endhighlight %}

![center](/figs/2021-01-11-art-collections/unnamed-chunk-3-1.png)


As seen from the above histogram plot, We see two apex in **Tate's acquisitions first, in year mid-19th century and second one in late-20th century**. Same thing happened, **with Art creation we saw increased in early 19th century and one in mid-20th century**. 
We can conclude that <mark>Tate acquisition mostly happened in 19th century in same period of art creation</mark>.


## Tale's Arts Dimension w.r.t Years


{% highlight r %}
artwork %>%
  filter(!is.na(width) | !is.na(height)) %>%
  mutate(dim = width*height) %>%
  ggplot(aes(x = year, y = log2(dim))) + 
  geom_point(colour = "#FAAB18") +
  geom_smooth(method = "auto", colour = "#555555") +
    # Labels
  labs(fill = "", y = "Dimensions", 
       x = "Year", title = "Tale's Acquired Arts Dimension", 
       subtitle = "Dimensions is in log2") +
  # theme 
  theme(legend.position = "top", 
        legend.text = element_text(family = "Helvetica", size = 14),
        axis.text = element_text(family = "Helvetica", size = 14),
        axis.title = element_text(family = "Helvetica", size = 14),
        plot.title = element_text(family = "Helvetica", size = 18, 
                                  face = "bold", color = "#222222"),
        plot.subtitle = element_text(family = "Helvetica", size = 16,
                                    color = "#222222"))
{% endhighlight %}

![center](/figs/2021-01-11-art-collections/unnamed-chunk-4-1.png)
  

## Predict the century in which artwork created.


{% highlight r %}
century <- cut(artwork$year, breaks = c(1500, 1600, 1700, 1800, 1900, 2000),
               labels = c("16th century","17th century","18th century",
                          "19th century", "20th century"))


# Set the random number stream using `set.seed()` so that the results can be 
# reproduced later.
set.seed(123)

# Save the split information for an 80/20 split of the data
century_split <- initial_split(century, prob = 0.80)
{% endhighlight %}



{% highlight text %}
## Error in initial_split(century, prob = 0.8): could not find function "initial_split"
{% endhighlight %}



{% highlight r %}
century_split
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): object 'century_split' not found
{% endhighlight %}



{% highlight r %}
# <Analysis/Assess/Total>

century_train <- training(century_split)
{% endhighlight %}



{% highlight text %}
## Error in training(century_split): could not find function "training"
{% endhighlight %}



{% highlight r %}
century_test  <-  testing(century_split)
{% endhighlight %}



{% highlight text %}
## Error in testing(century_split): could not find function "testing"
{% endhighlight %}



{% highlight r %}
dim(century_train)
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): object 'century_train' not found
{% endhighlight %}

  

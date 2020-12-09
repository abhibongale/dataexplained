---
layout: post
title: "IKEA Furniture prices- A tidy analysis"
description: "The weird Economics of Ikea"
output: html_document
date: "2020-12-09"
category: r
tags: [r, statistics]
comments: true
editor_options: 
  chunk_output_type: console
---




[The weird economics of ikea](https://fivethirtyeight.com/features/the-weird-economics-of-ikea/)

The Article explained how unique IKEA is and they are the only company in furniture (proving wrong to the analyst 15 years ago who predict they will have lots of competitors around the world). 

Let's look at what makes IKEA so unique how they sale there furniture.

## Explore data


{% highlight r %}
ikea <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-11-03/ikea.csv')
{% endhighlight %}


* Data contains `X1` variable which define row numbers. 
* `short_description` is messy.

We've done data preprocessing.

#### Clean data


{% highlight r %}
ikea_df <- ikea %>%
  select(-X1) %>%
  mutate(short_description = str_squish(short_description))
{% endhighlight %}


{% highlight r %}
ikea_df <- ikea %>%
  separate(short_description, c("main_description", "rest"),
           sep = ",", 
           extra = "merge",
           fill = "right") %>%
  extract(rest, "numbers", "([\\d\\-xX]+) cm", remove = FALSE)

ikea_df %>%
  count(category, main_description)
{% endhighlight %}



{% highlight text %}
## # A tibble: 1,012 x 3
##    category      main_description                      n
##    <chr>         <chr>                             <int>
##  1 Bar furniture Bar stool                             7
##  2 Bar furniture Bar stool with backrest              17
##  3 Bar furniture Bar stool with backrest frame         1
##  4 Bar furniture Bar table                             8
##  5 Bar furniture Bar table and 2 bar stools            6
##  6 Bar furniture Bar table and 4 bar stools            4
##  7 Bar furniture Cover for bar stool with backrest     1
##  8 Bar furniture Stool                                 1
##  9 Bar furniture Table                                 1
## 10 Bar furniture Wall-mounted drop-leaf table          1
## # … with 1,002 more rows
{% endhighlight %}

### Does `price` associate with furniture size?


{% highlight r %}
ikea_df %>%
  select(X1, price, depth:width) %>%
  pivot_longer(depth:width, names_to = "dim") %>%
  ggplot(aes(value, price, colour = dim)) +
  geom_point(alpha = 0.4, show.legend = FALSE) +
  scale_y_log10() +
  facet_wrap(~dim, scales = "free_x") +
  labs(x = NULL)
{% endhighlight %}

![center](/figs/2020-11-03-ikea-furniture/unnamed-chunk-4-1.png)

there is a relation between width and price. While we don't see any or there is a vague relation between `depth` and `height`.

Lets look at the volume vs price for each category.

{% highlight r %}
ikea_df %>%
  add_count(category, name = "category_total") %>%
  mutate(volume = depth*height*width, rm.na = TRUE,
         category = glue::glue("{category} ({category_total})")) %>%
  ggplot(aes(volume, price)) +
  geom_point(alpha = 0.4) +
  scale_y_log10(labels = scales::dollar_format()) +
  expand_limits(y = 0) +
  geom_smooth(method = "lm")
{% endhighlight %}

![center](/figs/2020-11-03-ikea-furniture/unnamed-chunk-5-1.png)

### What are the common item people prefer in terms of space/size?


{% highlight r %}
ikea_df %>%
  add_count(category, name = "category_total") %>%
  mutate(category = glue::glue("{category}({category_total})"),
         category = fct_reorder(category, price),
         volume = (depth*height*width)/10^6) %>%
  ggplot(aes(volume, category, fill = category)) +
  geom_density_ridges(alpha = .5) +
  theme(legend.position = "none") +
  geom_vline(xintercept = 1, colour = "red", lty = 2) +
  labs(x = "volume in cubic meter",
       y = "furniture category",
       title = "How much volune does each item have?",
       subtitle = "vertical red line represent 1 cubic meter")
{% endhighlight %}

![center](/figs/2020-11-03-ikea-furniture/unnamed-chunk-6-1.png)

People choose different lots of different wardrobes, Sofas and armchairs in terms of size. Room dividers category has only 13 data so we have to ignore that column.

### How `category` effects `price`?


{% highlight r %}
ikea_df %>%
  select(X1, price, category) %>%
  add_count(category, name = "category_total") %>%
  mutate(category = glue::glue("{category} ({category_total})"),
         category = fct_reorder(category, price)) %>%
  ggplot(aes(category, price)) +
  geom_boxplot(aes(fill = category), show.legend = FALSE) +
  scale_y_log10(labels = scales::dollar_format()) +
  coord_flip() +
  labs(title = "Prices according to the famous category",
       x = "",
       y = "Price")
{% endhighlight %}

![center](/figs/2020-11-03-ikea-furniture/unnamed-chunk-7-1.png)


## Linear Model 

So lets predict prices w.r.t to furniture volumes


{% highlight r %}
ikea_df <- ikea_df %>%
    mutate(volume = (depth*height*width)/10^6)
{% endhighlight %}



{% highlight r %}
ikea_lm <- ikea_df %>%
  select(volume, price, category) %>%
  lm(log2(price)~log2(volume) + category, data =.)

ikea_lm <- ikea_df %>%
  select(volume, price, category) %>%
  mutate(category = fct_relevel(category, "Tables & desks")) %>%
  lm(log2(price)~log2(volume)+category, data =.)

ikea_lm %>%
  summary()
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = log2(price) ~ log2(volume) + category, data = .)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -5.1816 -0.4674  0.0475  0.5529  4.5521 
## 
## Coefficients:
##                                              Estimate Std. Error
## (Intercept)                                  10.11429    0.09296
## log2(volume)                                  0.68998    0.01248
## categoryBar furniture                        -0.33446    0.20181
## categoryBeds                                  1.10249    0.13572
## categoryBookcases & shelving units           -0.47412    0.10004
## categoryCabinets & cupboards                  0.38920    0.10880
## categoryCafé furniture                       -0.07261    0.26206
## categoryChairs                               -0.33770    0.10701
## categoryChests of drawers & drawer units      0.24544    0.11945
## categoryChildren's furniture                 -0.59554    0.13364
## categoryNursery furniture                    -0.42568    0.14315
## categoryOutdoor furniture                    -0.33535    0.13333
## categoryRoom dividers                        -0.47913    0.37513
## categorySideboards, buffets & console tables  0.45786    0.21844
## categorySofas & armchairs                     0.66090    0.11211
## categoryTrolleys                              0.03402    0.30961
## categoryTV & media furniture                  0.02292    0.12799
## categoryWardrobes                             0.09444    0.11543
##                                              t value Pr(>|t|)    
## (Intercept)                                  108.799  < 2e-16 ***
## log2(volume)                                  55.293  < 2e-16 ***
## categoryBar furniture                         -1.657 0.097626 .  
## categoryBeds                                   8.123 8.13e-16 ***
## categoryBookcases & shelving units            -4.739 2.31e-06 ***
## categoryCabinets & cupboards                   3.577 0.000356 ***
## categoryCafé furniture                        -0.277 0.781763    
## categoryChairs                                -3.156 0.001626 ** 
## categoryChests of drawers & drawer units       2.055 0.040039 *  
## categoryChildren's furniture                  -4.456 8.83e-06 ***
## categoryNursery furniture                     -2.974 0.002980 ** 
## categoryOutdoor furniture                     -2.515 0.011978 *  
## categoryRoom dividers                         -1.277 0.201685    
## categorySideboards, buffets & console tables   2.096 0.036215 *  
## categorySofas & armchairs                      5.895 4.43e-09 ***
## categoryTrolleys                               0.110 0.912525    
## categoryTV & media furniture                   0.179 0.857865    
## categoryWardrobes                              0.818 0.413353    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.8903 on 1881 degrees of freedom
##   (1795 observations deleted due to missingness)
## Multiple R-squared:  0.7491,	Adjusted R-squared:  0.7468 
## F-statistic: 330.3 on 17 and 1881 DF,  p-value: < 2.2e-16
{% endhighlight %}

So we start with $10.191^2$ and for 1 $m^3$ volume increase price will increase $2^0.754$


### Conclusion

Goal of this analysis is to find the relation between price and other variables. Which category people buy most depending on size.

Here We can clearly see that for `wadrobe` and some other categories people go for bigger volumes. But TV  & media furniture people still prefer smaller size.

Prediction isn't because lots of items missing dimensions and lots of them have incorrect prediction. We might have to do webscraping from ikea furniture's Saudi Arabia website using the links(some links items are not avaliable) provided. Prediction here is bias towards bigger items like tables and wardrobes.

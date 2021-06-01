---
layout: post
title: "Ask a Manager"
description: ""
output: html_document
date: "2021-06-01"
category: r
tags: [r, tidytuesday, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---

![ask-a-manager](https://www.askamanager.org/wp-content/uploads/2019/09/cropped-aam-resize-1-550px_width.png)

*Tidy-Tuesday challenge about the salary survey a few weeks ago.*

Lots of womens living in United States responsed to the salary survey. So we will look into how the state, age, job type, education, experience overall and in the field effects the annual salary. 

Annual salary Forecasts like these are useful because they help us understand the most likely range for certain kind of talent.






{% highlight text %}
## 
## ── Column specification ──────────────────────────────────────────────────────────────
## cols(
##   timestamp = col_character(),
##   how_old_are_you = col_character(),
##   industry = col_character(),
##   job_title = col_character(),
##   additional_context_on_job_title = col_character(),
##   annual_salary = col_double(),
##   other_monetary_comp = col_character(),
##   currency = col_character(),
##   currency_other = col_character(),
##   additional_context_on_income = col_character(),
##   country = col_character(),
##   state = col_character(),
##   city = col_character(),
##   overall_years_of_professional_experience = col_character(),
##   years_of_experience_in_field = col_character(),
##   highest_level_of_education_completed = col_character(),
##   gender = col_character(),
##   race = col_character()
## )
{% endhighlight %}










{% highlight text %}
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
{% endhighlight %}

![center](/figs/2021-05-18-ask-a-manager/unnamed-chunk-5-1.png)


{% highlight text %}
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
{% endhighlight %}

![center](/figs/2021-05-18-ask-a-manager/unnamed-chunk-6-1.png)


{% highlight text %}
## Warning: Ignoring unknown parameters: binwidth, bins, pad
{% endhighlight %}

![center](/figs/2021-05-18-ask-a-manager/unnamed-chunk-7-1.png)







 










{% highlight text %}
## ! train/test split: preprocessor 1/1: There are new levels in a factor: NA
{% endhighlight %}



{% highlight text %}
## ! train/test split: preprocessor 1/1, model 1/1 (predictions): There are new levels in a factor: NA
{% endhighlight %}



{% highlight text %}
## ! train/test split: preprocessor 1/1: There are new levels in a factor: NA
{% endhighlight %}



{% highlight text %}
## x train/test split: preprocessor 1/1, model 1/1: Error: Missing data in columns: education_PhD.
{% endhighlight %}



{% highlight text %}
## Warning: All models failed. See the `.notes` column.
{% endhighlight %}






![center](/figs/2021-05-18-ask-a-manager/unnamed-chunk-16-1.png)




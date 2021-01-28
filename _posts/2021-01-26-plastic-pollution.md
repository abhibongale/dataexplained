---
layout: post
title: "Plastic Pollution"
description: "Analysis about plastic pollution - countries, types of plastic and companies that are heavily involved in the contribution of  plastic pollution. The data comes from [Break Free from Plastic](https://www.breakfreefromplastic.org/) courtesy of [Sarah Sauve](https://sarahasauve.wordpress.com/). "
output: html_document
date: "2021-01-28"
category: r
tags: [r, tidytuesday, tidyverse]
comments: true
editor_options: 
  chunk_output_type: console
---



## Introduction

![Image](https://images.pexels.com/photos/2827735/pexels-photo-2827735.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940)

[Photo by Lucien Wanda from Pexels](https://www.pexels.com/photo/piles-of-garbage-by-the-shore-2827735/)

This blog is about **Plastic Pollution**  We will look into the countries, types of plastic and companies that are heavily involved in the contribution of plastic pollution. The data comes from [Break Free from Plastic](https://www.breakfreefromplastic.org/) courtesy of [Sarah Sauve](https://sarahasauve.wordpress.com/). 


{% highlight r %}
library(tidyverse) # metadata of packages
theme_set(theme_light())
{% endhighlight %}

## Read the data

{% highlight r %}
plastics <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-01-26/plastics.csv')
{% endhighlight %}

## Explore the data

{% highlight r %}
skimr::skim(plastics)
{% endhighlight %}


Table: Data summary

|                         |         |
|:------------------------|:--------|
|Name                     |plastics |
|Number of rows           |13380    |
|Number of columns        |14       |
|_______________________  |         |
|Column type frequency:   |         |
|character                |2        |
|numeric                  |12       |
|________________________ |         |
|Group variables          |None     |


**Variable type: character**

|skim_variable  | n_missing| complete_rate| min| max| empty| n_unique| whitespace|
|:--------------|---------:|-------------:|---:|---:|-----:|--------:|----------:|
|country        |         0|             1|   4|  50|     0|       69|          0|
|parent_company |         0|             1|   1|  84|     0|    10823|          0|


**Variable type: numeric**

|skim_variable | n_missing| complete_rate|    mean|      sd|   p0|  p25|  p50|  p75|   p100|hist  |
|:-------------|---------:|-------------:|-------:|-------:|----:|----:|----:|----:|------:|:-----|
|year          |         0|          1.00| 2019.31|    0.46| 2019| 2019| 2019| 2020|   2020|▇▁▁▁▃ |
|empty         |      3243|          0.76|    0.41|   22.59|    0|    0|    0|    0|   2208|▇▁▁▁▁ |
|hdpe          |      1646|          0.88|    3.05|   66.12|    0|    0|    0|    0|   3728|▇▁▁▁▁ |
|ldpe          |      2077|          0.84|   10.32|  194.64|    0|    0|    0|    0|  11700|▇▁▁▁▁ |
|o             |       267|          0.98|   49.61| 1601.99|    0|    0|    0|    2| 120646|▇▁▁▁▁ |
|pet           |       214|          0.98|   20.94|  428.16|    0|    0|    0|    0|  36226|▇▁▁▁▁ |
|pp            |      1496|          0.89|    8.22|  141.81|    0|    0|    0|    0|   6046|▇▁▁▁▁ |
|ps            |      1972|          0.85|    1.86|   39.74|    0|    0|    0|    0|   2101|▇▁▁▁▁ |
|pvc           |      4328|          0.68|    0.35|    7.89|    0|    0|    0|    0|    622|▇▁▁▁▁ |
|grand_total   |        14|          1.00|   90.15| 1873.68|    0|    1|    1|    6| 120646|▇▁▁▁▁ |
|num_events    |         0|          1.00|   33.37|   44.71|    1|    4|   15|   42|    145|▇▃▁▁▂ |
|volunteers    |       107|          0.99| 1117.65| 1812.40|    1|  114|  400| 1416|  31318|▇▁▁▁▁ |

Every Country has `Grand Total` in `parent_company` is the summation of the total plastic produces in that particular country.  


## Highest plastic pollutant countries


{% highlight r %}
#Prepare data
plastics %>%
  filter(country != "EMPTY") %>%
  filter(parent_company == "Grand Total", year == "2019") %>%
  select(country, grand_total) %>%
  group_by(country) %>%
  summarise(total = sum(grand_total)) %>%
  mutate(country = fct_reorder(country, total)) %>%
  filter(total > 3000) %>%
  #Make plot
  ggplot(aes(country, total)) +
  geom_bar(stat = "identity", fill = "#FAAB18")  +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  labs(x = "",
       y = "total") +
  coord_flip() +
  labs(x = "",
       y = "",
       title = "Top Plastic Pollutant Countries",
       subtitle = "Total of different types of plastics") +
  theme( plot.title = element_text(family = "Helvetica", size = 20,
                                   face = "bold", color = "#222222"), 
        plot.subtitle = element_text(family = "Helvetica", size = 18, 
                                     margin = margin(9, 0, 9, 0)),
        axis.text = element_text(family = "Helvetica", size = 10, 
                                 color = "#222222")) 
{% endhighlight %}

![center](/figs/2021-01-26-plastic-pollution/unnamed-chunk-4-1.png)

We have filtered countries which have `grand_total` more than $3000$.
(**Note: Lot of missing data**, But it gives a overview). 

Countries which are miles ahead in plastic pollution according to data. 
* Taiwan
* Nigeria
* Philippines

Nearly 513 million tons of plastics wind up in the oceans every year out of which 80% is from just 20 countries in the World. While China, India and America are in the list of contributors to this havoc, other countries like Indonesia, Philippines, Vietnam, Sri Lanka, Thailand, Egypt, Malaysia, Nigeria, Bangladesh and South Africa contribute their own share in a considerable manner.

[worldatlas-article](https://www.worldatlas.com/articles/countries-putting-the-most-plastic-waste-into-the-oceans.html)

##  Type of plastic produce?


{% highlight r %}
#Prepare data
plastics %>%
  pivot_longer(hdpe:pvc, names_to = "plastic_type", values_to = "count") %>%
  mutate(country = fct_reorder(country, grand_total)) %>%
  filter(!is.na(count), count != 0) %>%
  # Make Plot
  ggplot(aes(plastic_type, count)) +
  geom_col(fill = "#990000") +
  geom_hline(yintercept = 0, size = 1, colour = "#333333") +
  scale_y_continuous(labels = scales::comma) +
  labs(x = "",
       y = "",
       title = "Types of plastic",
       subtitle = "Most Plastic Type Manufactured") +
  theme(axis.text.x = element_text(angle = 15), 
        plot.title = element_text(family = "Helvetica", size = 20, face = "bold", color = "#222222"), 
        plot.subtitle = element_text(family = "Helvetica", size = 16, 
                                     margin = margin(9, 0, 9, 0)),
        axis.text = element_text(family = "Helvetica", size = 10, 
                                 color = "#222222")) 
{% endhighlight %}

![center](/figs/2021-01-26-plastic-pollution/unnamed-chunk-5-1.png)

Most other (o) type is the most manufactured plastic. 

Look up the Details about the plastic types and products in which they used:

### 7 types of  plastic (harmful)

There are many different types of plastic out there, and they can be simply classified into 7 main categories –

#### 1. Polyethylene terephthalate (pet)

Commonly known as PET, this type of plastic can be most commonly seen as being sold as water bottles and soda bottles. Even ketchup usually comes in a bottle made out of PET. While according to studies it is said to be a food-grade plastic since it has no BPA. But on the flip side when this plastic is exposed to heat, it becomes highly toxic.

#### 2. High-density polyethylene (hdpe)

Commonly known as HDPE, the most common applications of this plastic are milk and juice bottles. This is basically a hard plastic that is strong and durable and is often used to store hygiene products. This plastic is also often termed as a safe plastic but is known to leach very harmful chemicals. Too much exposure to these chemicals leads to harmful effects on kids and juveniles.

#### 3. Polyvinyl chloride (pvc)

This plastic is also known as PVC and it is a very rigid yet flexible material. This makes it ideal for hardware purposes like plumbing pipes and so on. Other purposes of PVC include plastic containers, shrink wrap, toys for children, and wrappers for medicines. PVC contains DEHP, which can result in male traits becoming feminine. It basically disrupts natural human hormones to a fault.

#### 4. Low-density polyethylene (ldpe)

This is a much thinner plastic that is mostly used for trash bags and bread packers. They are also used as a lining for beverage cups. Even though it has no BPA, it does have harmful estrogenic chemicals.

#### 5. Polypropylene (pp)

Most commonly used for making takeaway food containers. Polypropylene, or PP, is harmful too, but not as harmful as the other plastics we have mentioned in this article. But with that being said, it does cause quite a few health issues as well.

#### 6. Polystyrene (ps)

Often referred to as Styrofoam, is the common material for making single-use disposable utensils

like plates and cups. It leaches styrene which is a well-known carcinogen. Styrene is especially harmful when exposed to heat.

#### 7. Other plastics (o)

Plastics that don’t fall in any of the above categories go into the last one. These plastics mostly leach BPA or BPS and are very harmful. They cause many different diseases and disorders like mood dysfunctions, sexual disorders, reproductive disorders, and are also known to be endocrine disrupters.

(**article link**: [harmful plastic types](https://www.plasticcollectors.com/blog/types-of-plastic-harmful-to-health/))



#### Highest producer's?


{% highlight r %}
#Prepare data
plastics %>%
  filter(!is.na(grand_total), parent_company != "Grand Total") %>%
  select(-c(country, empty, num_events, volunteers)) %>%
  pivot_longer(hdpe:pvc, names_to = "plastic_type", values_to = "count") %>%
  group_by(parent_company) %>%
  summarise(grand_sum = sum(grand_total)) %>%
  arrange(desc(grand_sum)) %>%
  mutate(parent_company = ifelse(parent_company == "The Coca-Cola Company",
                                 "Coca-Cola", parent_company),
         parent_company = ifelse(parent_company == "Universal Robina Corporation", "UNL Robina Corp.", parent_company)) %>%
  mutate(parent_company = fct_reorder(parent_company, grand_sum)) %>%
  head(10) %>%
  #Make Plot
  ggplot(aes(parent_company, grand_sum)) +
  geom_col(fill = "#1380A1") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_y_continuous(labels = scales::comma) +
  labs(x = "",
       y = "",
       title = "Top Plastic Pollutant Company",
       subtitle = "Total of different types of product manufacture") +
  theme(axis.text.x = element_text(angle = 15), 
        plot.title = element_text(family = "Helvetica", size = 20, face = "bold", color = "#222222"), 
        plot.subtitle = element_text(family = "Helvetica", size = 18, 
                                     margin = margin(9, 0, 9, 0)),
        axis.text = element_text(family = "Helvetica", size = 10, 
                                 color = "#222222")) 
{% endhighlight %}

![center](/figs/2021-01-26-plastic-pollution/unnamed-chunk-6-1.png)

Lots of plastics are unbranded, a considerable amount of Company names are missing ($NULL$, $null$). If we remove the unbranded, null, NULL we will get Top plastic producers.

## Top 10 highest plastic producing companies


{% highlight r %}
#Prepare data
top_company <- plastics %>%
  filter(!is.na(grand_total), parent_company != "Grand Total") %>%
  select(-c(country, empty, num_events, volunteers)) %>%
  pivot_longer(hdpe:pvc, names_to = "plastic_type", values_to = "count") %>%
  group_by(parent_company) %>%
  summarise(grand_sum = sum(grand_total)) %>%
  arrange(desc(grand_sum)) %>%
  filter(parent_company != "null", parent_company != "NULL", parent_company != "Unbranded") %>%
  head(10) %>%
  mutate(parent_company = ifelse(parent_company == "The Coca-Cola Company",
                                 "Coca-Cola", parent_company),
         parent_company = ifelse(parent_company == "Universal Robina Corporation", "UNL Robina Corp.", parent_company)) +
  mutate(parent_company = fct_reorder(parent_company, grand_sum))
{% endhighlight %}



{% highlight text %}
## Error in check_factor(.f): object 'parent_company' not found
{% endhighlight %}



{% highlight r %}
#Make plot
top_company %>%
  ggplot(aes(parent_company, grand_sum)) +
  geom_col(fill = "#1380A1") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  geom_text(aes(y = 10000, label = grand_sum), vjust = 0.5, colour = "white") +
  labs(x = "",
       y = "",
       title = "Top Plastic Pollutant Company",
       subtitle = "Total of different types of product manufacture") +
  theme(axis.text.x = element_text(angle = 15), 
        plot.title = element_text(family = "Helvetica", size = 20, face = "bold", color = "#222222"), 
        plot.subtitle = element_text(family = "Helvetica", size = 18, 
                                     margin = margin(9, 0, 9, 0)),
        axis.text = element_text(family = "Helvetica", size = 10, 
                                 color = "#222222")) 
{% endhighlight %}

![center](/figs/2021-01-26-plastic-pollution/unnamed-chunk-7-1.png)

Coca-Cola was the largest plastic polluter. (**Note: Lot of missing data**, But it gives a overview).

[Forbes Article](https://www.forbes.com/sites/trevornace/2019/10/29/coca-cola-named-the-worlds-most-polluting-brand-in-plastic-waste-audit/?sh=678cc92c74e0)

## Conclusion 
- Plastic Pollution is has become mainstream environmental problem Countries, companies should do more to tackle this problem.
- Awareness should be spread about plastic pollution and its harm

### To tackle this problem

The increasingly apparent single-use plastic problem highlights the need to tackle the issue, in part, with three strategies:

  - Smart consumer choices - Educating the consumer on the need and practice of recycling single-use plastics.
  
  - Easy and efficient recycling - Developing an infrastructure where recycling is easy for the consumer and efficient enough to be economically viable.
  
  - Breakaway from plastics - Encouraging companies to develop alternative materials to use beyond plastics and changing the mindset around their products to not rely solely on plastic single-use containers.
  
  There is no perfect solution and as long as plastic is an effective and inexpensive source material, political and environmental pressure is the primary mechanism by which they will be encouraged to change.

[Article](https://www.forbes.com/sites/trevornace/2019/10/29/coca-cola-named-the-worlds-most-polluting-brand-in-plastic-waste-audit/?sh=678cc92c74e0)

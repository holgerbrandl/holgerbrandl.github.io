---
layout: post
title: "Simple elegant caching using magrittr and quote"
description: ""
category: []
published: true
tags: [magritr, design patterns]
---
{% include JB/setup %}

Some Content 2


{% highlight r %}
summary(cars)
{% endhighlight %}



{% highlight text %}
##      speed           dist       
##  Min.   : 4.0   Min.   :  2.00  
##  1st Qu.:12.0   1st Qu.: 26.00  
##  Median :15.0   Median : 36.00  
##  Mean   :15.4   Mean   : 42.98  
##  3rd Qu.:19.0   3rd Qu.: 56.00  
##  Max.   :25.0   Max.   :120.00
{% endhighlight %}


{% highlight r %}
hallo <- 1+1
1+1
{% endhighlight %}



{% highlight text %}
## [1] 2
{% endhighlight %}



{% highlight r %}
par(mar = c(4, 4, 0.1, 0.1), omi = c(0, 0, 0, 0))
plot(cars)
{% endhighlight %}

![center](/figs/2015-03-01-simple-elegant-caching-using-magrittr-and-quoteunnamed-chunk-2-1.png) 


bal bla bla


{% highlight r %}
plot(1:10)
{% endhighlight %}

![center](/figs/2015-03-01-simple-elegant-caching-using-magrittr-and-quoteunnamed-chunk-3-1.png) 

{% highlight r %}
hist(rnorm(1000))
{% endhighlight %}

![center](/figs/2015-03-01-simple-elegant-caching-using-magrittr-and-quoteunnamed-chunk-3-2.png) 




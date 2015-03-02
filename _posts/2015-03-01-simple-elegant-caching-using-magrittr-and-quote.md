---
layout: post
title: "Simple elegant caching using magrittr and quote"
description: ""
category: []
published: true
tags: [magritr, design patterns]
---
{% include JB/setup %}

A common element of data-processing workflows are long(er) running method calls that return a stable result for some period of time. Typical examples are data-base queries to resources like [biomart](http://www.ensembl.org/biomart/martview), [kegg](http://www.bioconductor.org/packages/release/bioc/html/KEGGREST.html), [NCBI Eutils](http://www.ncbi.nlm.nih.gov/books/NBK25501/), or local data processing on semi-static large data (e.g. reference data sets).

There are various reasons why we  would often like to cache the results of such operations:

* To overcome tedious delays when interactively working with data
* To easily decouple local workflows from web-resources
* To prevent downtime of web-APIs from blocking local processing
* To create a simplistic form of intermediate result storage

Eg. consider the following example:


{% highlight r %}
require(biomaRt)
require(magrittr)
require(digest)
require(dplyr)

## this will take a while, but will always give the same result (
mart <- useDataset("drerio_gene_ensembl", mart = useMart("ensembl"))
genes <- getBM(attributes=c("ensembl_gene_id", "external_gene_name", "start_position"), mart=mart)

## ... do something with the gene information
{% endhighlight %}

Depending on the attributes being queried, such a call can take up to several minutes.  A simplistic caching scheme could be implemented just by


{% highlight r %}
cacheFile="genes.RData"
if(file.exists(cacheFile)){
  genes <- local(get(load(cacheFile)))
} else {
  mart <- useDataset("drerio_gene_ensembl", mart = useMart("ensembl"))
  genes <- getBM(attributes=c("ensembl_gene_id","external_gene_name", "start_position"), mart=mart)
  save(genes, file=cacheFile)
}
{% endhighlight %}
However this solution seems overly verbose, lacks readability and does not feel elegant. Thus, we developed a more streamlined solution, where (arbitrary) expressions are just lazily evaluated:


{% highlight r %}
cache_it <- function(expr, cacheName=paste0("cache_", substr(digest(expr), 1,6))){
    cacheFile <- paste0(".", cacheName, ".RData")

    if(file.exists(cacheFile)){
        local(get(load(cacheFile)))
    } else {
        result <- eval(expr)
        save(result, file=cacheFile)
        result
    }
}
{% endhighlight %}

It's basically the same idea but wrapped by a function. However, the key difference here is the use of lazy expression evaluation. Let's start with a simple usage example. All we need to provide is a quoted expression


{% highlight r %}
some_iris <- quote(iris %>% filter(Species=="setosa")) %>% cache_it()
{% endhighlight %}
By default we don't need to provide a name for the cache file, because `cacheName` is derived from the stringified expression using `digest`, but we can also provide a more descriptive name for the cache file:


{% highlight r %}
some_iris <- quote(iris %>% filter(Species=="setosa")) %>% cache_it("iris_subset")
{% endhighlight %}
By doing so the resulting cache file name will be `.iris_subset.RData` compared to the less descriptive  hash-name `.cache_9c39ba.RData` in the first example.


To make the idea of lazy evaluation more clear consider a slightly more verbose example, where a complex expression is provided as argument to `cache_it`:

{% highlight r %}
filtExpr <- quote({
  print("evaluating expression")
  iris %>% filter(Species=="setosa")
})

## evaluated
some_iris <- filtExpr %>% cache_it()
{% endhighlight %}



{% highlight text %}
## [1] "evaluating expression"
{% endhighlight %}



{% highlight r %}
## no longer evaluated because expression is the same
some_iris_cached <- filtExpr %>% cache_it()
{% endhighlight %}
When `cache_it` is called for the first time, the expression is actually evaluated. However, when being called again with the same expression as argument, the result is retrieved from the cache file (no print output).
This last example is a bit artificial, and is just presented that way to illustrate the lazy evaluation approach: Just in case a cache-file corresponding to an expression does not exist yet, the expression will be evaluated. In a realistic setup we would also not assign the expression to a variable, but simply use it as argument (without prior any assignment) to `cache_it` as shown in the examples before.

Coming back to the initial example, we can now do a lazily cached biomart query, which is robust against biomart downtime, network problems, and helps to reduce the re-runtime of our application.

{% highlight r %}
genes <- quote({
    mart <- useDataset("drerio_gene_ensembl", mart = useMart("ensembl"))
    genes <- getBM(attributes=c("ensembl_gene_id","external_gene_name", "start_position"), mart=mart)
  }) %>% cache_it()
{% endhighlight %}





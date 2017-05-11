---
layout: post
title: kscript as substitute for awk
description: "kscript is an alternative to tabular data processing in the shell"
categories: [kotlin]
comments: true
---


Among other [recently added](https://github.com/holgerbrandl/kscript/blob/master/NEWS.md#v13) features, [`kscript`](https://github.com/holgerbrandl/kscript) does now accept scripts as arguments. Facilitated by its [support library](https://github.com/holgerbrandl/kscript#support-api), this makes it possible to use it in an `awk`-like fashion. And although `kscript` is more designed for more complex _self-contained micro-applications_, it is still interesting to compare both tools with respect to tabular data processing.


So let's get started. A common usecase of `awk` selecting columns:


{% highlight bash %}
# fetech some example data
# wget -O flights.tsv https://git.io/v9MjZ
# head  -n 5 flights.tsv > some_flights.tsv 
awk -v OFS='\t' '{print $10, $1, $12}' some_flights.tsv
{% endhighlight %}




{% highlight text %}
## carrier	year	tailnum
## UA	2013	N14228
## UA	2013	N24211
## AA	2013	N619AA
## B6	2013	N804JB
{% endhighlight %}
To do the same with `kscript` we can do the following

{% highlight bash %}
kscript 'lines.split().select(10,1,12).print()' some_flights.tsv 
{% endhighlight %}




{% highlight text %}
## carrier	year	tailnum
## UA	2013	N14228
## UA	2013	N24211
## AA	2013	N619AA
## B6	2013	N804JB
{% endhighlight %}

The `kscript` solution is using Kotlin to implement the same functionality and is just slightly more verbose.

## How does it work?

When a one-liner is provided as script argument to `kscript`, it will add the following prefix header
```kotlin
//DEPS de.mpicbg.scicomp:kscript:1.2
import kscript.text.*
val lines = resolveArgFile(args)
```
The header serves 2 purposes. First it imports the support methods from [`kscript.text`](https://github.com/holgerbrandl/kscript-support-api/tree/master/src/main/kotlin/kscript/text). Second, it resolves the data input which is assumed either an argument file or `stdin` into a `Sequence<String>` named `lines`.

The resulting script will [be processed](https://github.com/holgerbrandl/kscript#inlined-usage) like any other by `kscript`.

In the example above several other elements of the [`kscript` support library](https://github.com/holgerbrandl/kscript-support-api):

* [`split()`](https://github.com/holgerbrandl/kscript-support-api/blob/1ecbdeecaa68d57a8b2365a42995d7ce3bee28a0/src/main/kotlin/kscript/text/Tables.kt#L37-L37) - splits the lines of an input stream into [Row](https://github.com/holgerbrandl/kscript-support-api/blob/1ecbdeecaa68d57a8b2365a42995d7ce3bee28a0/src/main/kotlin/kscript/text/Tables.kt#L26)s. The latter are just a [typealias](https://kotlinlang.org/docs/reference/type-aliases.html) for `List<String>`
* [`select()`](https://github.com/holgerbrandl/kscript-support-api/blob/1ecbdeecaa68d57a8b2365a42995d7ce3bee28a0/src/main/kotlin/kscript/text/Tables.kt#L109) - which allows to perform positive and negative selections. Both range and index syntax and combinations of both are supported.
* [`print()`](https://github.com/holgerbrandl/kscript-support-api/blob/1ecbdeecaa68d57a8b2365a42995d7ce3bee28a0/src/main/kotlin/kscript/text/Tables.kt#L64) - Joins rows and prints them to `stdout`


Separators characters can be optionally provided and default (using kotlin [default parameters](https://kotlinlang.org/docs/reference/functions.html#default-arguments)) to tab-delimiters.


## Examples

* [Add a new column to a file](http://stackoverflow.com/questions/7551991/add-a-new-column-to-the-file):


{% highlight bash %}
awk '{print $1, $2, "F11-"$7}' some_flights.tsv
{% endhighlight %}




{% highlight text %}
## year month F11-arr_time
## 2013 1 F11-830
## 2013 1 F11-850
## 2013 1 F11-923
## 2013 1 F11-1004
{% endhighlight %}

{% highlight bash %}
kscript 'lines.split().map { listOf(it[1], it[2], "F11-"+ it[7]) }.print()' some_flights.tsv 
{% endhighlight %}




{% highlight text %}
## month	day	F11-sched_arr_time
## 1	1	F11-819
## 1	1	F11-830
## 1	1	F11-850
## 1	1	F11-1022
{% endhighlight %}
Note that `kscript` is keeping the tab as a delimter for the output.

* [Delete a column](http://stackoverflow.com/questions/15361632/delete-a-column-with-awk-or-sed)


{% highlight bash %}
awk '!($3="")'  some_flights.tsv

kscript 'lines.split().select(-3).print()' some_flights.tsv 
{% endhighlight %}
As pointed out in the link, the `awk` solution is flawed and may not work for all types of input data. There also does not seem to be a generic `awk` solution to this problem. (`cut` will do it though)

* Number lines (from [here](http://tuxgraphics.org/~guido/scripts/awk-one-liner.html))


{% highlight bash %}
 awk '{print FNR "\t" $0}'  some_flights.tsv
 
 kscript 'lines.mapIndexed { num, line -> num.toString() + " " + line }.print()'  some_flights.tsv
{% endhighlight %}

* Delete trailing white space (spaces, tabs)


{% highlight bash %}
awk '{sub(/[ \t]*$/, "");print}' file.txt

kscript 'lines.map { it.trim() }.print()' file.txt
{% endhighlight %}

* Print the lines from a file starting at the line matching "start" until the line matching "stop":


{% highlight bash %}
awk '/start/,/stop/' file.txt

kscript 'lines.dropWhile { it.startsWith("foo") }.takeWhile { it.startsWith("bar") }.print()' file.txt
{% endhighlight %}


* Print the last field in each line delimited by ':'


{% highlight bash %}
awk -F: '{ print $NF }' file.txt
kscript 'lines.split(":").map { it[it.size - 1] }.print()' file.txt
{% endhighlight %}

* [Prints Record(line) number, and number of fields in that record](http://www.thegeekstuff.com/2010/01/8-powerful-awk-built-in-variables-fs-ofs-rs-ors-nr-nf-filename-fnr/?ref=binfind.com/web)


{% highlight bash %}
awk '{print NR,"->",NF}' file.txt

kscript 'lines.split().mapIndexed { index, row -> index.toString() + " -> " + row.size }.print()'
{% endhighlight %}

So as we can see we can just use regular _Kotlin_ to solve most `awk` use-cases easily. And keep in mind that `kscript` is not meant to be _just_ a table processor, for which we pay here with an extra in verbosity (which could be refactored into more specialized support library methods, but which is kept for sake of readability).


## Performance

To assess differences in runtime we use the initial column sub-setting example to process 300k flights


{% highlight bash %}
wc -l flights.tsv
time awk '{print $10, $1, $12}' flights.tsv > /dev/null
{% endhighlight %}




{% highlight text %}
##   336777 flights.tsv
## 
## real	0m5.602s
## user	0m2.998s
## sys	0m0.097s
{% endhighlight %}

{% highlight bash %}
time kscript 'lines.split().select(10,1,12).print()' flights.tsv > /dev/null
{% endhighlight %}




{% highlight text %}
## 
## real	0m6.525s
## user	0m3.688s
## sys	0m0.822s
{% endhighlight %}
Both solutions do not differ signifcantly in runtime. However, this actually means that  `kscript` is processing the data faster, because we loose around 350ms because of the JVM startup. To illustrate that point we redo the benchmark with 20x of the data.


{% highlight bash %}
# moreFlights="flights.tsv flights.tsv flights.tsv flights.tsv flights.tsv"
# cat ${moreFlights} ${moreFlights} ${moreFlights} ${moreFlights} > many_flights.tsv
time awk '{print $10, $1, $12}' many_flights.tsv > /dev/null
{% endhighlight %}

{% highlight bash %}
time kscript 'lines.split().select(10,1,12).print()' many_flights.tsv > /dev/null
{% endhighlight %}
For the tested usecase, __`kscript` seems more than 30% faster than `awk`__. Long live the JIT compiler! :-)


## Conceptual Clarity vs Convenience

One of the core motivations for the development of `kscript` is **long-term stability** of `kscript`lets. However, by adding a prefix header including a versioned dependency for the [kscript support API](https://github.com/holgerbrandl/kscript-support-api) we are somehow condemned to either stick to the current version of the support api for all times, or to hope that gradual improvements do not break existing kscript solutions. Neither option does sound appealing.

Because of that, we still consider to replace/drop the support for automatic prefixing of one-liners. The more verbose solution including the prefix-header would be fixed (and thus long-term stable) even if we evolve the support API, but for sure conciseness would suffer a  lot. See yourself:

```
kscript 'lines.split().select(with(1..3).and(3)).print()' file.txt
```
vs.

```
kscript '//DEPS de.mpicbg.scicomp:kscript:1.2
import kscript.text.*
val lines = resolveArgFile(args)

lines split().select(with(1..3).and(3)).print()
'
```
Readability would be better in the latter case because it is a self-contained Kotlin application.

Opinions and suggestions on this feature are welcome!


## Summary

As we have discussed above, `kscript` can be used as a drop-in replacement for awk in situations where `awk` solutions would become overly clumsy. By allowing for standard kotlin to write little pieces of shell processing logic, we can avoid installing external dedicated tools in many solutions. Although, `kscript`s written in `Kotlin` are slightly more verbose than `awk` code, they are more readable and allow to express more complex data flow logic.

Whereas as table streaming is certainly possible with `kscript` and beneficial in some situations, its true _true power_ is the handling of more complex data-types, such as  _json_, and _xml_, and domain specific data like _fasta_ or alignment files in bioinformatics. Because of the built-in dependency resolution in `kscript` third party libraries can be easily used in short concise mini-programs for a wide range of application domains. We plan to discuss examples in the next article.


Feel welcome to post questions or comments.


{% include comments.html %}

---
layout: post
title: Upgrade your workflow with 0-installation kotlin scriptlets
description: "Use kscript and kotlin snippets for versioned zero-deployment tool development"
categories: [kotlin]
comments: true
---


In common bioinformatics/scientific workflows black magic bash hacking skills are often required and used to process data. This is because these workflows tend to live in the bash-shell and for many data processing tasks there is no actual little nifty tool. Omnipresent on _solution repositories_ like [biostar](https://www.biostars.org/) or [stackoverflow](http://stackoverflow.com/) are crazy combinations of perl, grep, awk, that tend to very cryptic even to experienced data monkeys. More high-level solution in python or R can be developed but often lack the portability necessary to enable colleagues to run those solutions without additional setup efforts.
   
To overcome this problem, I've evolved a small extension tool to named [`kscript`](https://github.com/holgerbrandl/kscript) over the last months. It allows to easily embed [Kotlin](https://kotlinlang.org/) scriptlets into the shell, and ships with features like compile-jar-caching and automatic dependency resolution. Just see its [github page](https://github.com/holgerbrandl/kscript) for details and examples.  


Although `kscript` has helped to create readable kotlin solutions for a range of data flow problems, it was still a bit tedious to ship around developed solutions in a concise and user-friendly manner. To overcome this problem, I've recently enhanced `kscript` to also allow for URLs as scriptlet sources.

Let's do an example. Imagine you'd need to filter a list of genomic sequences saved in a [fasta-formatted](https://en.wikipedia.org/wiki/FASTA_format) file by length. This is how the data may look like:

```
>HSBGPG Human gene for bone gla protein (BGP)
GGCAGATTCCCCCTAGACCCGCCCGCACCATGGTCAGGCATGCCCCTCCTCATCGCTGGGCACAGCCCAGAGGGT
ATAAACAGTGCTGGAGGCTGGCGGGGCAGGCCAGCTGAGTCCTGAGCAGCAGCCCAGCGCAGCCACCGAGACACC
CTCCAGGCACCCTTCTTTCCTCTTCCCCTTGCCCTTGCCCTGACCTCCCAGCCCTATGGATGTGGGGTCCCCATC
ATCCCAGCTGCTCCCAAATAAACTCCAGAAG
>HSGLTH1 Human theta 1-globin gene
CCACTGCACTCACCGCACCCGGCCAATTTTTGTGTTTTTAGTAGAGACTAAATACCATATAGTGAACACCTAAGA
CGGGGGGCCTTGGATCCAGGGCGATTCAGAGGGCCCCGGTCGGAGCTGTCGGAGATTGAGCGCGCGCGGTCCCGG
GATCTCCGACGAGGCCCTGGACCCCCGGGCGGCGAAGCTGCGGCGCGGCGCCCCCTGGAGGCCGCGGGACCCCTG
TCAGCCCCGCGCTGCAGGCGTCGCTGGACAAGTTCCTGAGCCACGTTATCTCGGCGCTGGTTTCCGAGTACCGCT
GAACTGTGGGTGGGTGGCCGCGGGATCCCCAGGCGACCTTCCCCGTGTTTGAGTAAAGCCTCTCCCAGGAGCAGC
CTTCTTGCCGTGCTCTCTCGAGGTCAGGACGCGAGAGGAAGGCGC
>ARGH1 Transcriptional regulartor
ATCCAGGGCGATTCAGAGGGCCCCGGGCCACGTTATCTCGGCGCTGGTTTCGCGCTGGTTTCGCGCTGGTTTCGCG
CTGGTTTCC
```
 
 For sure, there are tons of ways to solve this. E.g. using a tool called `samtools faidx` with downstream filtering of it's output using `awk`. Or by reformating the commonly multi-line fasta into single, line via `perl` plus some `awk` and so on. [BioPyton](https://github.com/biopython/biopython.github.io/) or [BioPerl](http://bioperl.org/) also do the trick, are very readable, but require installation and additional setup efforts.

To allow for **0-installation scriptlets** that do their own automatic dependency resolution, `kscript` comes to rescue. Here's a  Kotlin solution for the filter problem from above, which we'll work through step by step:
 
```kotlin
 //DEPS de.mpicbg.scicomp:kutils:0.4
 //KOTLIN_OPTS -J-Xmx2g
 
 import de.mpicbg.scicomp.bioinfo.openFasta
 import java.io.File
 import kotlin.system.exitProcess
 
 if (args.size != 2) {
     System.err.println("Usage: fasta_filter <fasta> <length_cutoff>")
     exitProcess(-1)
 }
 
 val fastaFile = File(args[0])
 val lengthCutoff = args[1].toInt()
 
 
 openFasta(fastaFile).
     filter { it.sequence.length >= lengthCutoff }.
     forEach { print(it.toEntryString()) }
```

* First a single dependency is added that provides a Kotlin API to parse fasta-formatted data. 
* Because some of the sequences might be large we want to run with 2gb of memory. Since it is supposed to be a self-contained mini-program it ships a simplistic CLI involving just an input file and the length-cutoff. 
* The implementation is straightforward: It creates an iterator over the entries in the fasta-file, which is filtered by length and the remaining entries are printed to stdout. 

Because of Kotlin's nice and concise collections API and syntax, the solution should be readable almost even to non-developers. ;-)

Previously `kscript` allowed to run such scriptlets either by saving the them as a file or by inlining (See it's [docs]((https://github.com/holgerbrandl/kscript)) for more examples):

```bash
## simply read the script from stdin
echo 'println("hello world")' | kscript -

## or read it from a file
echo 'println("hello world")' > test.kts
kscript test.kts
```

However, since recently `kscript` also can also read URLs which evlevates its usage to a new level. So since the fasta length filter scriplet from above was deposited as a [gist](https://gist.github.com/holgerbrandl/521a5e9b1eb0d5b443b82cf13f66074f) on github, we can now simply write

```bash
kscript https://git.io/v1ZUY test.fasta 20 > filtered.fasta
```

To further increase readability and convenience, we can `alias` the first part

```bash
alias fasta_length_filter="kscript https://git.io/v1ZUY"

fasta_length_filter ~/test.fasta 20 > filtered.fasta
```

When being invoked without arguments `fasta_length_filter` will provide just the usage info.

Depending on the users' preference the URL could point either to the master revision of the gist or to a particular revision for better reproducibility. Since the scriplet is versioned along with its dependencies (which ware fetched via `maven`), this approach does not depend on API stability for the external libraries being used -- a common problem which is tedious to overcome when working with python, R or perl! In contrast `kscript` solutions provide absolute **long-term stability** (within the limits of a hardly ever changing JVM and the kotlin compiler).

In this post I've discussed how to write versioned, bootstrapping mini-programs using `kscript` and `Kotlin`. In my next posting I'll talk about the support APi for `kscript` to allow for `awk`-like one-liners written in Kotlin to please they eye instead of being confusing and `aw(k)`ful.
 

{% include comments.html %}

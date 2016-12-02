---
layout: page
title: Data should flow not stumble through code
tagline: Meditations on Data, R, Kotlin and the universe
---
{% include JB/setup %}

This blog contains ideas, snippets, and contributions to [R](http://www.r-project.org/) and [Kotlin](https://kotlinlang.org/).

My name is Holger Brandl. I love (or at least try hard) to write efficient, concise and elegant R. I would like to share some of my R creations via this blog. I'm always curious to explore new ways and tools to streamline data processing. 

I've implemented an R plugin for [Intellij IDEA](https://www.jetbrains.com/idea) called [R4Intellij](https://github.com/holgerbrandl/r4intellij). I'm also in love with kotlin and it's applications to bioinformatics and data engineering, e.g [kscript](https://github.com/holgerbrandl/kscript) for simplified shell integration of kotlin snippets or [krangl](https://github.com/holgerbrandl/krangl) for in-memory table crunching. 

## A bit more about the author


I hold a [PhD degree](http://pub.uni-bielefeld.de/publication/2305544) in machine learning, have [developed](http://dblp.uni-trier.de/pers/hd/b/Brandl:Holger) some new concepts in the field of computational linguistics, and have recently co-authored publications in [Nature](http://www.nature.com/nature/journal/v500/n7460/full/nature12414.html) and [Sciene](http://www.sciencemag.org/content/early/2015/02/25/science.aaa1975.abstract).  Currently, I'm working as a data scientist at the [Max Planck Institute of Molecular Cell Biology and Genetics](http://mpi-cbg.de/) in Dresden, Germany.

On major motivation for this blog is to get feedback from other data professionals about the way I use R. So please feel welcome to comment on my articles or to contact me via [email](holgerbrandl+blog@gmail.com). To get in touch with my open-source contributions please visit my [github profile](https://github.com/holgerbrandl) where you can also find the [sources](https://github.com/holgerbrandl/holgerbrandl.github.io) of this blog.


## Recent Blot Articles

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>

## Acknowledgements

* [Disqus](https://disqus.com/) for hosting and providing the comments section of this blog
* [Jekyll](http://jekyllrb.com/) which generates this blog directly from markdown
* [Twittter Bootstrap](http://getbootstrap.com/) for their great css/js  framework used to style this content


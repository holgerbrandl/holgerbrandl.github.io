---
layout: post
title: "Sortable, searchable, paginated tables with knitr and jquery.DataTables"
categories: [knitr]
comments: true
---

<link rel="stylesheet" type="text/css" href="http://cdn.datatables.net/1.10.5/css/jquery.dataTables.min.css">
<script type="text/javascript" charset="utf8" src="http://code.jquery.com/jquery-2.1.2.min.js"></script>
<script type="text/javascript" charset="utf8" src="http://cdn.datatables.net/1.10.5/js/jquery.dataTables.min.js"></script>

<script type="text/javascript">
         $(document).ready(function() {
            // alert("test")
             //$("table").DataTable();
             $("table").DataTable();
             //$("#tab_id").DataTable();
             //$(".dtable").DataTable();
         } );
</script>

Creating reports with [knitr](http://yihui.name/knitr/) is becoming increasingly popular. Those documents are beautiful because they tightly link code to results. One drawback is that they lack an interactive element compared to server-client solutions like [shiny](http://shiny.rstudio.com/). More recently java-script based solutions like [rcharts](http://rcharts.io/), [plotly](https://plot.ly/r/), [htmlwidgets](http://www.htmlwidgets.org/), [SortableHTMLTables](http://cran.r-project.org/web/packages/SortableHTMLTables/index.html) have started to overcome this limitation and allow for dynamic interactive reporting using R-Markdown.

One popular way to add interactivity to html tables in the web-development community, is to use the powerful and elegant [DataTable](http://www.datatables.net/) module, which is a plug-in for the [jQuery](http://jquery.com/). In this article we show how knitr and DataTables can be mixed to generated sortable, searchable, paginated tables using just Rmarkdown.

### Setup

Somewhere at the beginning of our Rmd we need to setup the jquery/DataTable infrastructure by simply including the following lines

    <link rel="stylesheet" type="text/css" href="http://cdn.datatables.net/1.10.5/css/jquery.dataTables.min.css">
    <script src="http://code.jquery.com/jquery-2.1.2.min.js"></script>
    <script src="http://cdn.datatables.net/1.10.5/js/jquery.dataTables.min.js"></script>

    <script type="text/javascript">
             $(document).ready(function() {
                 $("table").DataTable();
             } );
    </script>


To get started we need data, thus we load `ggplot` and for convenience also `dplyr`.

{% highlight r %}
require(dplyr)
require(ggplot2)
{% endhighlight %}



Now we can create sortable, paginated, searchable tables by adding a chunk with the option <code>results='asis'</code>


{% highlight r %}
iris %>%  kable()
{% endhighlight %}



|    | Sepal.Length| Sepal.Width| Petal.Length| Petal.Width|Species    |
|:---|------------:|-----------:|------------:|-----------:|:----------|
|127 |          6.2|         2.8|          4.8|         1.8|virginica  |
|1   |          5.1|         3.5|          1.4|         0.2|setosa     |
|124 |          6.3|         2.7|          4.9|         1.8|virginica  |
|65  |          5.6|         2.9|          3.6|         1.3|versicolor |
|4   |          4.6|         3.1|          1.5|         0.2|setosa     |
|118 |          7.7|         3.8|          6.7|         2.2|virginica  |
|148 |          6.5|         3.0|          5.2|         2.0|virginica  |
|94  |          5.0|         2.3|          3.3|         1.0|versicolor |
|70  |          5.6|         2.5|          3.9|         1.1|versicolor |
|59  |          6.6|         2.9|          4.6|         1.3|versicolor |
|123 |          7.7|         2.8|          6.7|         2.0|virginica  |
|138 |          6.4|         3.1|          5.5|         1.8|virginica  |
|79  |          6.0|         2.9|          4.5|         1.5|versicolor |
|86  |          6.0|         3.4|          4.5|         1.6|versicolor |
|106 |          7.6|         3.0|          6.6|         2.1|virginica  |
|136 |          7.7|         3.0|          6.1|         2.3|virginica  |
|96  |          5.7|         3.0|          4.2|         1.2|versicolor |
|134 |          6.3|         2.8|          5.1|         1.5|virginica  |
|44  |          5.0|         3.5|          1.6|         0.6|setosa     |
|50  |          5.0|         3.3|          1.4|         0.2|setosa     |

The scheme is not limited to a single table, but we can embed as many as we like

{% highlight r %}
mtcars %>% kable()
{% endhighlight %}



|                    |  mpg| cyl|  disp|  hp| drat|    wt|  qsec| vs| am| gear| carb|
|:-------------------|----:|---:|-----:|---:|----:|-----:|-----:|--:|--:|----:|----:|
|Valiant             | 18.1|   6| 225.0| 105| 2.76| 3.460| 20.22|  1|  0|    3|    1|
|Hornet 4 Drive      | 21.4|   6| 258.0| 110| 3.08| 3.215| 19.44|  1|  0|    3|    1|
|Cadillac Fleetwood  | 10.4|   8| 472.0| 205| 2.93| 5.250| 17.98|  0|  0|    3|    4|
|AMC Javelin         | 15.2|   8| 304.0| 150| 3.15| 3.435| 17.30|  0|  0|    3|    2|
|Fiat X1-9           | 27.3|   4|  79.0|  66| 4.08| 1.935| 18.90|  1|  1|    4|    1|
|Ferrari Dino        | 19.7|   6| 145.0| 175| 3.62| 2.770| 15.50|  0|  1|    5|    6|
|Hornet Sportabout   | 18.7|   8| 360.0| 175| 3.15| 3.440| 17.02|  0|  0|    3|    2|
|Merc 450SL          | 17.3|   8| 275.8| 180| 3.07| 3.730| 17.60|  0|  0|    3|    3|
|Honda Civic         | 30.4|   4|  75.7|  52| 4.93| 1.615| 18.52|  1|  1|    4|    2|
|Merc 450SLC         | 15.2|   8| 275.8| 180| 3.07| 3.780| 18.00|  0|  0|    3|    3|
|Ford Pantera L      | 15.8|   8| 351.0| 264| 4.22| 3.170| 14.50|  0|  1|    5|    4|
|Pontiac Firebird    | 19.2|   8| 400.0| 175| 3.08| 3.845| 17.05|  0|  0|    3|    2|
|Mazda RX4           | 21.0|   6| 160.0| 110| 3.90| 2.620| 16.46|  0|  1|    4|    4|
|Merc 240D           | 24.4|   4| 146.7|  62| 3.69| 3.190| 20.00|  1|  0|    4|    2|
|Dodge Challenger    | 15.5|   8| 318.0| 150| 2.76| 3.520| 16.87|  0|  0|    3|    2|
|Lotus Europa        | 30.4|   4|  95.1| 113| 3.77| 1.513| 16.90|  1|  1|    5|    2|
|Lincoln Continental | 10.4|   8| 460.0| 215| 3.00| 5.424| 17.82|  0|  0|    3|    4|
|Toyota Corona       | 21.5|   4| 120.1|  97| 3.70| 2.465| 20.01|  1|  0|    3|    1|
|Volvo 142E          | 21.4|   4| 121.0| 109| 4.11| 2.780| 18.60|  1|  1|    4|    2|
|Merc 280C           | 17.8|   6| 167.6| 123| 3.92| 3.440| 18.90|  1|  0|    4|    4|

### Links

To also allow for interactive links we have to render html with `kable` without escaping the data:

{% highlight r %}
iris %>%
    mutate(Species=paste0("<a href='https://www.google.com/?q=",Species,"'>",Species,"</a>")) %>%
    kable("html", escape=F)
{% endhighlight %}

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> Sepal.Length </th>
   <th style="text-align:right;"> Sepal.Width </th>
   <th style="text-align:right;"> Petal.Length </th>
   <th style="text-align:right;"> Petal.Width </th>
   <th style="text-align:left;"> Species </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 6.2 </td>
   <td style="text-align:right;"> 2.8 </td>
   <td style="text-align:right;"> 4.8 </td>
   <td style="text-align:right;"> 1.8 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=virginica'>virginica</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.1 </td>
   <td style="text-align:right;"> 3.5 </td>
   <td style="text-align:right;"> 1.4 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=setosa'>setosa</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6.3 </td>
   <td style="text-align:right;"> 2.7 </td>
   <td style="text-align:right;"> 4.9 </td>
   <td style="text-align:right;"> 1.8 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=virginica'>virginica</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.6 </td>
   <td style="text-align:right;"> 2.9 </td>
   <td style="text-align:right;"> 3.6 </td>
   <td style="text-align:right;"> 1.3 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=versicolor'>versicolor</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4.6 </td>
   <td style="text-align:right;"> 3.1 </td>
   <td style="text-align:right;"> 1.5 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=setosa'>setosa</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7.7 </td>
   <td style="text-align:right;"> 3.8 </td>
   <td style="text-align:right;"> 6.7 </td>
   <td style="text-align:right;"> 2.2 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=virginica'>virginica</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6.5 </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:right;"> 5.2 </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=virginica'>virginica</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.0 </td>
   <td style="text-align:right;"> 2.3 </td>
   <td style="text-align:right;"> 3.3 </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=versicolor'>versicolor</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.6 </td>
   <td style="text-align:right;"> 2.5 </td>
   <td style="text-align:right;"> 3.9 </td>
   <td style="text-align:right;"> 1.1 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=versicolor'>versicolor</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6.6 </td>
   <td style="text-align:right;"> 2.9 </td>
   <td style="text-align:right;"> 4.6 </td>
   <td style="text-align:right;"> 1.3 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=versicolor'>versicolor</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7.7 </td>
   <td style="text-align:right;"> 2.8 </td>
   <td style="text-align:right;"> 6.7 </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=virginica'>virginica</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6.4 </td>
   <td style="text-align:right;"> 3.1 </td>
   <td style="text-align:right;"> 5.5 </td>
   <td style="text-align:right;"> 1.8 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=virginica'>virginica</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6.0 </td>
   <td style="text-align:right;"> 2.9 </td>
   <td style="text-align:right;"> 4.5 </td>
   <td style="text-align:right;"> 1.5 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=versicolor'>versicolor</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6.0 </td>
   <td style="text-align:right;"> 3.4 </td>
   <td style="text-align:right;"> 4.5 </td>
   <td style="text-align:right;"> 1.6 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=versicolor'>versicolor</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7.6 </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:right;"> 6.6 </td>
   <td style="text-align:right;"> 2.1 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=virginica'>virginica</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7.7 </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:right;"> 6.1 </td>
   <td style="text-align:right;"> 2.3 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=virginica'>virginica</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.7 </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:right;"> 4.2 </td>
   <td style="text-align:right;"> 1.2 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=versicolor'>versicolor</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6.3 </td>
   <td style="text-align:right;"> 2.8 </td>
   <td style="text-align:right;"> 5.1 </td>
   <td style="text-align:right;"> 1.5 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=virginica'>virginica</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.0 </td>
   <td style="text-align:right;"> 3.5 </td>
   <td style="text-align:right;"> 1.6 </td>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=setosa'>setosa</a> </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5.0 </td>
   <td style="text-align:right;"> 3.3 </td>
   <td style="text-align:right;"> 1.4 </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:left;"> <a href='https://www.google.com/?q=setosa'>setosa</a> </td>
  </tr>
</tbody>
</table>

### Selective interactivity

Most of the time we do not need interactivity for all tables, but just for a subset for them. To achieve this, the jquery selector in the initialization method is changed to `$(".dtable")` and we decorate the tables that should be interactive with a `dtable` class attribute:

{% highlight r %}
iris %>% kable("html", table.attr = "class='dtable'", escape=F)
{% endhighlight %}
Using this scheme we can now selectively render tables as simple html or if needed as dynamic DataTables.


### Wrap up

By mixing `jquery` with `knitr` we've created a simplistic but yet very powerful scheme to include dynamic tables into R Markdown documents. Not covered here, but natural next steps, could be a function wrapper for `kable` to streamline the inclusion of the jquery libraries, or more DataTable customizations to allow for  [columnn filters](http://jquery-datatables-column-filter.googlecode.com/svn/trunk/index.html), toggable [column visibility](https://datatables.net/extensions/colvis/), or to include any of the DataTable [extensions](https://datatables.net/extensions/). In most cases those will require almost no coding effort and are almost invisible when writing the R Markdown.


## Update

Since I've written this blog post the folks from [RStudio](http://www.rstudio.com/) have released [DT package](http://rstudio.github.io/DT/) which essentially hides the logic described in this article. However, at the moment it seems quite tied to rstudio so I think it's still interesting to understand the undlying mechanism (which is what this article was about).

{% include comments.html %}

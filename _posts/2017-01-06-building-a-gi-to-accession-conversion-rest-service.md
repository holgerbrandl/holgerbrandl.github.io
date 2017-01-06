---
layout: post
title: Building a GI to accession conversion REST service using spring-boot and kotlin
description: "sdfsdf"
categories: [kotlin]
comments: true
---

Recently, the [NCBI retired ](https://www.ncbi.nlm.nih.gov/news/03-02-2016-phase-out-of-GI-numbers/)the well known GI numbers in favor of the more structured accession numbers. To allow users to still convert existing data, they [provide](https://ncbiinsights.ncbi.nlm.nih.gov/2016/12/23/converting-lots-of-gi-numbers-to-accession-version/) a python 40gb lmdb database along with a little python program to extract the data. However, since it's rather tedious to pull a 40gb file, and make sure to have all required python dependencies, we would like to wrap this conversion model into a small REST service.
 

## Prepare the mapping model

First, We simply pull the massive data file - which is a python [Lightning database](https://lmdb.readthedocs.io/en/release/) - to our local system and test the provided python tool to test the installation. 

```bash
cd ~/gi_acc
wget ftp://ftp.ncbi.nlm.nih.gov/genbank/livelists/gi2acc_mapping/gi2acc_lmdb.db.2017.01.04.0001.gz.*
gunzip gi2acc_lmdb.db.2017.01.04.0001.gz

ln -s gi2acc_lmdb.db.2017.01.04.0001 gi2acc_lmdb.db

## also download the provided script
wget ftp://ftp.ncbi.nlm.nih.gov/genbank/livelists/gi2acc_mapping/gi2accession.py

## test the provided tool
chmod u+x gi2accession.py 

## install required python modules
#sudo apt-get install python-dev
pip install lmdb

## try an example to test the installation
echo 42 | ./gi2accession.py 
#> 42	CAA44840.1	416
```
To avoid this tedious setup whenever we need to convert GIs, we would like to expose it via a tiny REST API.

## Setup the REST application

The general concept about to get started with REST, Spring-Boot and Kotlin is described in 

* https://spring.io/blog/2016/02/15/developing-spring-boot-applications-with-kotlin
* http://www.thedevpiece.com/building-microservices-with-kotlin-and-springboot/
* http://ssoudan.eu/posts/2014-12-08-kotlin-springboot.html

So essentially all we need is a single method taking one or more GIs and returning a mapping scheme:
```{kotlin}
// value type to model python-script output
data class IdPair(val gi: Long, val accession: String?, val seqLength: Long?)

// installation dir of ncbi provided pyton script and database
//val INSTALL_DIR = File(System.getProperty("user.home"), "projects/gi_acc")
val INSTALL_DIR = File("/local/web/files/gi2acc_service/")



@RestController
class IdConversionController {

    @RequestMapping("/gi2acc")
    fun mapGI(@RequestParam(value = "gi") giNumbers: String): List<IdPair> {
        val queryGis = giNumbers.split(',', ';').map(String::toInt).toList()

        val idListFile = createTempFile()

        queryGis.saveAs(idListFile)

        // run the python script over the ids
        val cmd = "cat ${idListFile.absolutePath} | ${INSTALL_DIR}/gi2accession.py"
        val result = evalBash(cmd, wd = INSTALL_DIR)

        val convertedIds: List<IdPair> = result.stdout.
                filter(String::isNotBlank).
                map {
                    // if id was not mappable return NA instead (example 5353)
                    if (it.contains("not found")) {
                        IdPair(it.split(" ")[0].toLong(), null, null)
                    } else {
                        // example line: 34	X17614.1	1632
                        with(it.split('\t')) { IdPair(this[0].toLong(), this[1], this[2].toLong()) }
                    }
                }

        idListFile.delete()

        return convertedIds
    }
}

@SpringBootApplication
open class Application

fun main(args: Array<String>) {
    // http://stackoverflow.com/questions/21083170/spring-boot-how-to-configure-port
    System.getProperties().put("server.port", 7050);

    SpringApplication.run(Application::class.java, *args)
}
```


There's just a single method that accepts a list of comma/semicolon separated GIs and returns a json structure with the mapping. Unmappable IDs are mapped to NA.

We notice and welcome the surprisingly little amount of boilerplate code required to turn it into a Spring-Boot ready application. Only a specially annotated `Application` class is needed which is used as an argument to `SpringApplication.run` in the main function of the kts. Kotlin makes it possible to keep everything in a single class here.

To test the app locally we can use use `http://localhost:7050/gi2acc?gi=42` or `http://localhost:7050/gi2acc?gi=123,222, 232,3` for multiple IDs.

To check if also invalid GI are handled gracefully we can mix in an invalid id `http://localhost:7050/gi2acc?gi=23,5353,34`, which gives:
```json
[
  {
    "gi": 23,
    "accession": "X53811.1",
    "seqLength": 422
  },
  {
    "gi": 5353,
    "accession": null,
    "seqLength": null
  },
  {
    "gi": 34,
    "accession": "X17614.1",
    "seqLength": 1632
  }
]
```


## How to deploy the app into production?

To deploy our micro-service into production we simply follow the spring-boot [deployment guidelines](http://docs.spring.io/spring-boot/docs/current/reference/html/deployment-install.html).  

```bash
## Build it
gradle build

## Copy to server (this steo will depend on your local setup)
scp build/libs/gi2acc_service-1.0-SNAPSHOT.jar java-srv1:/local/web/files/gi2acc_service/gi2acc_service.jar

## Change to deployment server target directory, and then 
chmod o+x gi2acc_service.jar  ## make it executable

## Use special user created with "sudo adduser bootapp" to increase app-security 
## (see spring-boot docs link from above for details) 
sudo chown bootapp:bootapp gi2acc_service.jar
sudo chmod 500 gi2acc_service.jar  ## only owner can read and write


## Now we could just run it directly...
sudo su bootapp
./gi2acc_service.jar


## ... or install as an init.d service (recommended)
sudo ln -s $(readlink -f gi2acc_service.jar) /etc/init.d/gi2acc

## start the service
sudo service gi2acc start
## or stop it
sudo service gi2acc stop
```

Test the installation with simply with `curl "http://java-srv1.mpi-cbg.de:7050/gi2acc?gi=23,5353,34"` or in your [browser](http://java-srv1.mpi-cbg.de:7050/gi2acc?gi=23,5353,34).


## Workflow integration

Finally, we'd lik to use our new GI to accession conversion microservice. Since most bioinformatic workflows live in R or the shell, we'll show integrations for both here. Let's start with R:

### How to integrate with R?

Using the conversion webservice from R can be easily done using [httr](https://github.com/hadley/httr) + [dplyr](https://github.com/hadley/dplyr) mixed with a bit of [purr](https://github.com/hadley/purrr):
```r
library(httr)
library(tidyverse)
library(dplyr)

## define the queries
GIs = list(23,5353,34)

## iterate over the queries, call the service, and bind the results into a data.frame
idMap = map_df(GIs, function(gi_nr){
#    gi_nr=5353
    paste0("http://bioinfo.mpi-cbg.de:7050/gi2acc?gi=", gi_nr) %>% 
        GET %>% 
        content %>% 
        flatten %>%
        with(data.frame(gi=gi, accession= ifelse(is.null(accession), NA, accession)))
}) 

idMap
#     gi accession
# 1   23  X53811.1
# 2 5353      <NA>
# 3   34  X17614.1

```

### How to use it in bash?

Since the shell is not really made for json we'd like to [convert the output into csv](
http://stackoverflow.com/questions/32960857/how-to-convert-arbirtrary-simple-json-to-csv-using-jq) to allow more bash-style processing of the converted GIs. There are [various solutions ](http://stackoverflow.com/questions/1955505/parsing-json-with-unix-tools)to process json in the shell. We recommend [jq](https://stedolan.github.io/jq/):

```bash
# install jq if not yet present: sudo apt-get install jq
gi_nr=24,323

curl -s "http://bioinfo.mpi-cbg.de:7050/gi2acc?gi=$gi_nr" | jq -r '(.[0] | keys) as $keys | $keys, map([.[ $keys[] ]])[] | @csv'
```
which gives
```
"accession","gi","seqLength"
"X53812.1",24,422
"CAA32192.1",323,155
```


### How to use it in Kotlin?

Since we used kotlin for the service backend, we might want it for the client-side as well. To do so we use [Fuel](https://github.com/kittinunf/Fuel) and [Klaxon](https://github.com/cbeust/klaxon):

```kotlin
import com.beust.klaxon.*
import com.github.kittinunf.fuel.httpGet

// define list of query GIs
val gis = listOf(23,5353,34)

val queryURL = "http://bioinfo.mpi-cbg.de:7050/gi2acc?gi=${gis.joinToString(",")}"

val json = String(queryURL.httpGet().response().second.data)

// use fuel library to call the service (see https://github.com/kittinunf/Fuel)
val jsonArray = Parser().parse(json.byteInputStream())!! as JsonArray<*>

// use klaxon library to parse the json result (see https://github.com/cbeust/klaxon)
val idMap = jsonArray.map { (it as JsonObject) }.map { it.int("gi") to it.string("accession") }

// print conversion table
idMap.forEach { println(it) }
```
which gives
```
(23, X53811.1)
(5353, null)
(34, X17614.1)
```

This solution could be also easily wrapped into a self-contained client-side application using [kscript](https://github.com/holgerbrandl/kscript), by just adding a dependency header and by reading the id list from the provided arguments. See here how it looks like

```bash
## define a convenience wrapper 
alias gi2acc="kscript https://raw.githubusercontent.com/holgerbrandl/gi2accession/master/parse_json.kts"

## use it!
gi2acc 23 324 534
#> (23, X53811.1)
#> (324, X53689.1)
#> (534, X67823.1)
```

## Summary

With little effort we could build, and deploy a spring-boot application providing a REST service for GI to accession number conversion. Because of Kotlin's more flexible design we could keep things together in a single source file. We walked through different integrations using R, the shell, and Kotlin.

The complete code is available unter https://github.com/holgerbrandl/gi2acc_service

The described conversion service can be used via the following URL:
```
http://java-srv1.mpi-cbg.de:7050/gi2acc?gi=23,5353,34
```
 
Feel welcome to post comments or suggestions.


{% include comments.html %}

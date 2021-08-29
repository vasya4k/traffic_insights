# traffic insights

This repository contains a project to create a pipeline to ingest and process sFlow data.
All the components apart from pmacct are running using docker-compose.

## Start a flow pipeline

You can run the pipeline using docker-compose file which contains following services:
* [GoFlow](https://github.com/cloudflare/goflow)
* Kafka/Zookeeper
* kafkasflowes to export data from Kafka to Elasticserach
* Elasticsearch and Kibana to store and analyse the data
* Nginx to add auth for Kibana 
* initialiser to add dashboards and mappings for ES

It will listen on port 6343/UDP for sFlow

A pipeline looks like this:
```



                       +------+         +-----+
    pmacct(sFlow) ->   |goflow+--------->Kafka| Topic: flows
                       +------+         +-----+
                                           |
                                           +---------------------+
                                           |                     |
                                           |                     |
                                     +-----v--------+       +----v------+
                                     | kafkasflowes |       |new service|
                                     +--------------+       +-----------+
                                           |
                                           |
                                        +--v-------------+
                                        |  Elasticsearch |
                                        |     Kibana     |
                                        +----------------+

```

The exporter(kafkasflowes) will query GeoIP DB and add info about countries, ASN, device info.

## How to run 



## What is next

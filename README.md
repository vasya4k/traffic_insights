# traffic insights

This repository contains a project to create a pipeline to ingest and process sFlow data.
All the components apart from pmacct are running using docker-compose. 
You need to install docker and docker-compose on your box.

## Start a flow pipeline

You can run the pipeline using a docker-compose file, which contains the following services:
* [GoFlow](https://github.com/cloudflare/goflow)
* Kafka/Zookeeper
* kafkasflowes to export data from Kafka to Elasticserach
* Elasticsearch and Kibana to store and analyse the data
* Nginx to add auth for Kibana 
* initialiser to add dashboards and mappings for ES

The pipeline looks like this:
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


## Config example for accounting daemon pmacctd 

cat /etc/pmacct/pmacctd.conf
      ! pmacctd configuration
      daemonize: true
      pidfile: /var/run/pmacctd.pid
      syslog: daemon
      ! use sFlow plugin 
      plugins: sfprobe
      ! interface to listen on 
      pcap_interface: eth0
      ! sample every 5th packet
      sampling_rate: 5
      sfprobe_agentsubid: 1402
      ! destination for sFlow data 
      sfprobe_receiver: [127.0.0.1]:5678

To install pmacct on Ubuntu: 

sudo apt install pmacct

Once you have installed pmacct you should check that it is running.

sudo systemctl status pmacctd.service
[sudo] password for bob:
● pmacctd.service - promiscuous mode accounting daemon
     Loaded: loaded (/lib/systemd/system/pmacctd.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2021-08-11 18:48:51 NZST; 4 weeks 0 days ago
   Main PID: 1252 (pmacctd)
      Tasks: 2 (limit: 18967)
     Memory: 11.1M
     CGroup: /system.slice/pmacctd.service
             ├─1252 pmacctd: Core Process [default]
             └─1253 pmacctd: sFlow Probe Plugin [default_sfprobe]

Aug 11 18:48:50 bob4k systemd[1]: Starting promiscuous mode accounting daemon...
Aug 11 18:48:51 bob4k pmacctd[1252]: INFO ( default/core ): Start logging ...
Aug 11 18:48:51 bob4k pmacctd[1252]: INFO ( default/core ): Promiscuous Mode Accounting Daemon, pmacctd 1.7.2-git (20181018-00+c3)
Aug 11 18:48:51 bob4k pmacctd[1252]: INFO ( default/core ):  '--build=x86_64-linux-gnu' '--prefix=/usr' '--includedir=${prefix}/include' '--mandir=${prefix}/share/man' '--infodir=${prefix}/share/info' '--sysconfdir=/etc' '--localstatedir=/var' '--disable-silent-rules' '--libdir=${prefix}/lib/x86_64-linux-gnu' '--libexecdir=${prefix}/lib/>
Aug 11 18:48:51 bob4k pmacctd[1252]: INFO ( default/core ): Reading configuration file '/etc/pmacct/pmacctd.conf'.
Aug 11 18:48:51 bob4k pmacctd[1253]: INFO ( default_sfprobe/sfprobe ): Exporting flows to [0.0.0.0]:5678
Aug 11 18:48:51 bob4k pmacctd[1253]: INFO ( default_sfprobe/sfprobe ): Sampling at: 1/5
Aug 11 18:48:51 bob4k systemd[1]: Started promiscuous mode accounting daemon.
Aug 11 18:48:51 bob4k pmacctd[1252]: INFO ( default/core ): [eth0,0] link type is: 1
Aug 11 18:48:51 bob4k pmacctd[1252]: WARN ( default/core ): eth0: no IPv4 address assigned

## How to run 

First, if you want geolocation to work you need to download the database files from https://dev.maxmind.com/geoip/geolite2-free-geolocation-data 
Next, move into the nginx dir and change the password using htpasswd -b .htpasswd username password. You might need to install htpasswd tool. 
Update router mac address in the mac table. Then change the working directory to kafka_sflow open ksflowes.toml file set geoip = true if you downloaded the DB files. 
Move back into traffic_insights dir and run docker-compose up --force-recreate 

## What is next

Navigate to yourboxip:8080 to log in to Kibana. 
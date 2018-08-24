![](https://user-images.githubusercontent.com/4025771/44583199-7e492c80-a7a4-11e8-9e92-e8580e05ab43.png)

## Architecture

<div style="text-align:center"><img src ="https://user-images.githubusercontent.com/4025771/44580729-56a19680-a79b-11e8-97f6-e48ce39cb891.png" /></div>

You can use our [prozzie](https://github.com/wizzie-io/prozzie) like *Source of data*

## Requirements

We recommend a machine with at least:

* 4 CPU
* 16 GB RAM
* 30 GB disk

Also, you need to install docker and docker-compose

* [Docker](https://store.docker.com/search?type=edition&offering=community)
* [Docker Compose](https://docs.docker.com/compose/install/)

Finally, you need to download or clone this repo on the machine.

## Configuration

You only need to configure the `.env` file. Inside it, you can find three sections:

* **MANDATORY**: You need to configure this vars before run the application.
* **OPTIONAL**: You can configure this vars, if you want to change some configurations or enable some features.
* **STATIC**: You must not change this vars.  

***Note:*** *On some linux distribution you need to open the iptables on the machine, to send data from outside to Kafka broker (port: 9092).*


## Execution

Now, you only need to run the docker-compose inside repo folder:

```
docker-compose up
```

You can check using `docker-compose ps` inside repo folder.

```
root@kubeubuntu:~/community-stack# docker-compose ps
                   Name                                 Command               State               Ports
-------------------------------------------------------------------------------------------------------------------
wizziecommunitystack_druid-broker_1          /bin/sh -c druid-start.sh        Up       0.0.0.0:8080->8080/tcp
wizziecommunitystack_druid-coordinator_1     /bin/sh -c druid-start.sh        Up
wizziecommunitystack_druid-historical_1      /bin/sh -c druid-start.sh        Up
wizziecommunitystack_druid-init_1            /bin/bash -c /bin/bash -c  ...   Exit 0
wizziecommunitystack_druid-middlemanager_1   /bin/sh -c druid-start.sh        Up
wizziecommunitystack_druid-overlord_1        /bin/sh -c druid-start.sh        Up       0.0.0.0:8084->8084/tcp
wizziecommunitystack_enricher_1              /bin/sh -c exec /bin/enric ...   Up
wizziecommunitystack_kafka_1                 start-kafka.sh                   Up       0.0.0.0:9092->9092/tcp
wizziecommunitystack_normalizer_1            /bin/sh -c exec /bin/norma ...   Up
wizziecommunitystack_postgres_1              docker-entrypoint.sh postgres    Up       5432/tcp
wizziecommunitystack_redis_1                 docker-entrypoint.sh redis ...   Up       6379/tcp
wizziecommunitystack_sidekiq_1               scripts/docker-entrypoint- ...   Up
wizziecommunitystack_wizz-vis_1              scripts/docker-entrypoint- ...   Up       0.0.0.0:3000->3000/tcp
wizziecommunitystack_zookeeper_1             /docker-entrypoint.sh zkSe ...   Up       2181/tcp, 2888/tcp, 3888/tcp
wizziecommunitystack_zz-cep_1                /bin/sh -c exec /bin/cep-s ...   Up
```

## Ports Binding

| Service        | Port           | Usage                             |
| :------------- | :------------- | :-------------------------------- |
| Kafka          | 9092           | Send data to wizzie stack         |
| WizzVis        | 3000           | Access to visualization interface |
| Druid Broker   | 8080           | Query data using druid API        |
| Druid Overlord | 8084           | Manage indexing tasks             |

## Extra documentation

* [Normalizer docs](https://wizzie-io.github.io/normalizer/)
* [Enricher docs](https://wizzie-io.github.io/enricher/)
* [ZZ-CEP docs](https://wizzie-io.github.io/zz-cep/)
* WizzVis API docs (Comming soon!)
* [Druid Kafka Indexing tasks docs](http://druid.io/docs/latest/development/extensions-core/kafka-ingestion.html)
* [Druid Querying docs](http://druid.io/docs/latest/querying/querying.html)
* [Kafka Operations docs](https://kafka.apache.org/documentation/#basic_ops)

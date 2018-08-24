# Wizzie Community Stack

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
* **OPTINAL**: You can configure this vars, if you want to change some configurations or enable some features.
* **STATIC**: You must not change this vars.  

***Note:*** *On some linux distribution you need to open the iptables on the machine, to send data from outside to Kafka broker (port: 9092).*


## Execution

Now, you only need to run the docker-compose inside repo folder:

```
docker-compose up
```

## Ports Binding

| Service        | Port           | Usage                             |
| :------------- | :------------- | :-------------------------------- |
| Kafka          | 9092           | Send data to wizzie stack         |
| WizzVis        | 3000           | Access to visualization interface |
| Druid Broker   | 8080           | Query data using druid API        |
| Druid Overlord | 8084           | Manage indexing tasks             |

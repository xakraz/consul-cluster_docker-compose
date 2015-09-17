consul-cluster_docker-compose
------------------------------

<!-- TOC depth:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Overview](#overview)
- [Getting Started](#getting-started)
	- [1 - Build the image](#1-build-the-image)
	- [2 - Update the docker-compose file](#2-update-the-docker-compose-file)
	- [3 - Start the cluster](#3-start-the-cluster)
	- [4 - Use the UIs](#4-use-the-uis)
- [Details](#details)

<!-- /TOC -->


# Overview

# Getting Started

## 1 - Build the image

```shell
docker build -t <YOUR_TAG_NAME> --file=Dockerfile .
```


## 2 - Update the docker-compose file

[docker-compose.yml](docker-compose.yml)

Stuff to update:

* Image: Name of the image you have just built;
* Ports: Mapping per instances (to avoid port collision on Host)
* Environment: ```CONSUL_OPTS``` (passed to ```consul agent``` to define)
  - How many members you want for boostrapping
  - Who to join for the other members
  - What ever other options you would need


```yaml
$ cat docker-compose.yml
---
consul1:
  image: sandbox/consul-server
  hostname: consul1
  ports:
   - "8301:8300"
   - "8401:8400"
   - "8501:8500"
   - "8601:8600"
   - "9001:9001"
  environment:
   - CONSUL_OPTS=-bootstrap-expect=3

consul2:
  image: sandbox/consul-server
  hostname: consul2
  links:
   - consul1
  ports:
   - "8302:8300"
   - "8402:8400"
   - "8502:8500"
   - "8602:8600"
   - "9002:9001"
  environment:
   - CONSUL_OPTS=-rejoin -retry-join=consul1

...
```

## 3 - Start the cluster

```shell
docker-compose up
```

## 4 - Use the UIs

* Supervisor: [http://DOCKER_IP:900X]
* Consul UI: [http://DOCKER_IP:850X]


# Details

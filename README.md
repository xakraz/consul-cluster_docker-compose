consul-cluster_docker-compose
------------------------------

<!-- TOC depth:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Overview](#overview)
	- [1 - Components](#1-components)
- [Getting Started](#getting-started)
	- [1 - Build the image](#1-build-the-image)
	- [2 - Update the docker-compose file](#2-update-the-docker-compose-file)
	- [3 - Start the cluster](#3-start-the-cluster)
	- [4 - Use the UIs](#4-use-the-uis)
- [Details](#details)
	- [1 - Caveats](#1-caveats)
		- [supervisor / Environment variables](#supervisor-environment-variables)

<!-- /TOC -->


# Overview

## 1 - Components

* Base *Debian:squeeze*
* *Supervisor* process management
* *Consul* Agents


> Debian Squeeze Base image for Sandbox purpose
> * easier to customize
> * easier to work with Attached Shell for debugging purpose




# Getting Started

## 1 - Build the image

```shell
docker build -t <YOUR_TAG_NAME> --file=Dockerfile .
```


## 2 - Update the docker-compose file

[docker-compose.yml](docker-compose.yml)

Stuff to update:

* **Image**: Name of the image you have just built;
* **Ports**: Mapping per instances (to avoid port collision on Host)
* **Environment**: ```CONSUL_OPTS``` (passed to ```consul agent``` to define)
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


Creating consul1_1...
Creating consul2_1...
Creating consul3_1...
Attaching to consul1_1, consul2_1, consul3_1
...
consul1_1 | 2015-09-18 07:16:27,558 WARN Included extra file "/etc/supervisor/conf.d/01-consul-server.conf" during parsing
...
consul3_1 | 2015-09-18 07:16:29,111 WARN Included extra file "/etc/supervisor/conf.d/01-consul-server.conf" during parsing
...
consul2_1 | 2015-09-18 07:16:28,193 WARN Included extra file "/etc/supervisor/conf.d/01-consul-server.conf" during parsing
...

consul1_1 | 2015-09-18 07:16:30,216 INFO success: consul entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
consul2_1 | 2015-09-18 07:16:30,251 INFO success: consul entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
consul3_1 | 2015-09-18 07:16:31,208 INFO success: consul entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
```

## 4 - Use the UIs

* Supervisor: [http://DOCKER_IP:900X]
* Consul UI: [http://DOCKER_IP:850X]


# Details

## 1 - Caveats

### supervisor / Environment variables

In order to **use Environment variables** via Docker engine in **Supervisor**
 - => Have to **wrapp** the ```consul``` command with Bash ....

See:
* http://supervisord.org/configuration.html#program-x-section-settings
* http://stackoverflow.com/questions/12900402/supervisor-and-environment-variables
* http://blog.trifork.com/2014/03/11/using-supervisor-with-docker-to-manage-processes-supporting-image-inheritance/



[01-consul-server.conf](supervisor/conf.d/01-consul-server.conf)

```
$ cat supervisor/conf.d/01-consul-server.conf

[program:consul]
directory=/opt/consul

command=/bin/bash -x -c "printenv && /bin/consul agent -config-dir /opt/consul/conf ${CONSUL_OPTS}"

stdout_logfile=/opt/consul/logs/consul-stdout.log
stderr_logfile=/opt/consul/logs/consul-error.log
numprocs=1
autostart=true
autorestart=true
stopsignal=INT
```

# Viadeo - Consul Server mimic
#
#
FROM debian:squeeze
MAINTAINER "Xavier Krantz <xakraz@gmail.com>"


## Base
## --
RUN apt-get update
RUN apt-get install -y --force-yes\
 unzip \
 supervisor

COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 9001



## Consul
## --
## Dir Layout
ENV CONSUL_HOME /opt/consul
RUN mkdir -p ${CONSUL_HOME}/conf \
  && mkdir -p ${CONSUL_HOME}/data \
  && mkdir -p ${CONSUL_HOME}/logs

## Binary
ENV CONSUL_VERSION 0.5.2
ENV CONSUL_SHA256 171cf4074bfca3b1e46112105738985783f19c47f4408377241b868affa9d445

ADD https://dl.bintray.com/mitchellh/consul/${CONSUL_VERSION}_linux_amd64.zip /tmp/consul.zip
RUN echo "${CONSUL_SHA256}  /tmp/consul.zip" > /tmp/consul.sha256 \
 && sha256sum -c /tmp/consul.sha256 \
 && cd /bin \
 && unzip /tmp/consul.zip \
 && chmod +x /bin/consul \
 && rm /tmp/consul.zip

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

## Consul - UI
ADD https://dl.bintray.com/mitchellh/consul/${CONSUL_VERSION}_web_ui.zip /tmp/webui.zip
RUN cd /tmp \
 && unzip webui.zip \
 && mv dist ${CONSUL_HOME}/ui \
 && rm webui.zip

## Consul - Conf
COPY consul/* ${CONSUL_HOME}/conf/
COPY supervisor/conf.d/* /etc/supervisor/conf.d/


## Service
## --
CMD ["supervisord", "-n"]



FROM debian:stretch-slim

ARG DEBIAN_FRONTEND=noninteractive

ENV PUID=1000
ENV PGID=1000

RUN apt-get -qq update && \
	apt-get -qq upgrade && \
	apt-get -qq install \
		git \
		curl \
		gnupg2 \
		apt-utils \
		apt-transport-https \
	&& \
	apt-get -qq autoremove && \
	apt-get -qq clean

COPY start.sh /

###############################################
#        EDIT TEMPLATE AFTER THIS LINE        #
###############################################

ENV CONT_USER=nagflux
ENV CONT_CMD="/opt/nagflux/nagflux -configPath /opt/nagflux/config/config.gcfg"

RUN apt-get -qq update && \
	apt-get -qq upgrade && \
	apt-get -qq install \
		golang \
		golang-github-influxdb-usage-client-dev \
	&& \
	apt-get -qq autoremove && \
	apt-get -qq clean

ENV GOPATH=/opt/gorepo

RUN useradd -u ${PUID} ${CONT_USER}

RUN mkdir ${GOPATH} && \
	go get -v -u github.com/griesbacher/nagflux && \
	go build github.com/griesbacher/nagflux && \
	mkdir -p /opt/nagflux/config && \
	cp $GOPATH/bin/nagflux /opt/nagflux && \
	mkdir -p /usr/local/nagios/var/spool/nagfluxperfdata && \
	chown ${CONT_USER}:${CONT_USER} /usr/local/nagios/var/spool/nagfluxperfdata

VOLUME /opt/nagflux/config

CMD ["/start.sh"]
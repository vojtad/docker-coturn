FROM buildpack-deps:18.04
LABEL maintainer="Vojta Drbohlav <vojta.d@gmail.com>"

EXPOSE 3478/tcp
EXPOSE 3478/udp
EXPOSE 5349/tcp
EXPOSE 5349/udp

ENV ANONYMOUS=0
ENV USERNAME=username
ENV PASSWORD=password

ENV REALM=realm

ENV LISTENING_PORT=3478
ENV TLS_LISTENING_PORT=5349

ENV LISTENING_IPS=
ENV RELAY_IPS=
ENV EXTERNAL_IPS=

ENV MIN_PORT=49152
ENV MAX_PORT=65535

RUN \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y coturn dnsutils iproute2 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /app

ADD entrypoint.sh .

ENTRYPOINT ["/app/entrypoint.sh"]

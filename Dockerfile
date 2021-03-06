FROM alpine:latest

MAINTAINER Thierry Couture <thierry@arabrab.com>

#
# Install all required dependencies.
#

RUN apk --update upgrade && \
    apk add --update bind && \
    apk add --update dhcp && \    
    rm -rf /var/cache/apk/*

#
# Add named init script.
#

ADD init.sh /init.sh
RUN chmod 750 /init.sh

#
# Define container settings.
#

VOLUME ["/etc/bind", "/var/log/named"]
VOLUME ["/etc/dhcp", "/var/lib/dhcp/"]

EXPOSE 53/udp
EXPOSE 67/udp 67/tcp

WORKDIR /etc/bind

#
# Start named.
#

CMD ["/init.sh"]

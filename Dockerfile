FROM haproxy:1.6.5-alpine

RUN mkdir /etc/haproxy

RUN apk add --no-cache curl bash
RUN curl -k -L https://github.com/kelseyhightower/confd/releases/download/v0.12.0-alpha3/confd-0.12.0-alpha3-linux-amd64 > /bin/confd && chmod +x /bin/confd

ADD entrypoint.sh /entrypoint.sh
ADD confd /etc/confd

CMD ["/entrypoint.sh"]
EXPOSE 8080


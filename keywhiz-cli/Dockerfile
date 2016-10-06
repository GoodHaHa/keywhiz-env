FROM maven:3.3-jdk-8

RUN git clone https://github.com/square/keywhiz.git
RUN cd keywhiz;mvn package -am -pl cli
COPY init /init
COPY ca-bundle.p12 /truststore.p12
COPY .env /opt/

ENTRYPOINT ["/init"]


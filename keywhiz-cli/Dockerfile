FROM maven:3.3-jdk-8

RUN git clone https://github.com/square/keywhiz.git
RUN cd keywhiz;mvn package -am -pl cli
COPY init /init

ENTRYPOINT ["/init"]


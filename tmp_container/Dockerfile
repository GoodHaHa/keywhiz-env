# based on Martijn Koster's "https://github.com/makuk66/docker-oracle-java7"

FROM ubuntu:trusty
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get upgrade -y && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get -y install oracle-java8-installer && \
    update-alternatives --display java && \
    apt-get -y install oracle-java8-set-default && \
    rm -fr /var/cache/oracle-jdk8-installer && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
ENV LANGUAGE   en_US:en

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


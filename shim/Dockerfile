FROM ubuntu:focal
MAINTAINER binnan_hao<haobinnan@gmail.com>

#update sources.list
# COPY sources.list /etc/apt/sources.list
#update sources.list

RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y devscripts dos2unix

#set git proxy
# RUN git config --global http.proxy http://192.168.1.66:10809
#set git proxy

RUN mkdir /work
WORKDIR /work

COPY mk-shim.sh .
COPY CertFile.cer .

RUN chmod +x mk-shim.sh && \
    ./mk-shim.sh

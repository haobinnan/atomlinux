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

#git
RUN git clone --branch isoo-shim-20210423-2 https://github.com/haobinnan/shim-review.git
WORKDIR /shim-review
#git

#local
# RUN mkdir -p /shim-review/Patches
# WORKDIR /shim-review
# COPY mk-shim.sh CertFile.cer ./
# COPY Patches ./Patches/
#local

RUN chmod +x mk-shim.sh && \
    ./mk-shim.sh

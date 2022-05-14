FROM debian:bullseye
MAINTAINER binnan_hao<haobinnan@gmail.com>

#update sources.list
# COPY sources.list /etc/apt/sources.list
#update sources.list

RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y devscripts dos2unix pesign

#set git proxy
# RUN git config --global http.proxy http://192.168.1.66:10811
#set git proxy

#git
RUN git clone --branch isoo-shim-20220311 https://github.com/haobinnan/shim-review.git
WORKDIR /shim-review
#git

#local
# RUN mkdir -p /shim-review/Patches
# WORKDIR /shim-review
# COPY mk-shim.sh CertFile.cer generate_dbx_list dbx.hashes ./
# COPY Patches ./Patches/
#local

RUN chmod +x mk-shim.sh && \
    ./mk-shim.sh

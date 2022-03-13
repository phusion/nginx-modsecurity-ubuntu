FROM ubuntu:20.04

ADD . /nginx_modsecurity_build
RUN /nginx_modsecurity_build/install.sh

USER app
ENV LC_ALL=C.UTF-8
ENV CCACHE_COMPRESS=1
ENV CCACHE_COMPRESSLEVEL=3
ENV PATH=/usr/lib/ccache:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENTRYPOINT ["/sbin/matchhostfsowner"]

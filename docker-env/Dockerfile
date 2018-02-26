FROM ubuntu:18.04
ADD . /nginx_modsecurity_build
RUN /nginx_modsecurity_build/install.sh
ENTRYPOINT ["/sbin/inithostmount"]

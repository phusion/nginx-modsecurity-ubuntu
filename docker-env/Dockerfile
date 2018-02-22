FROM ubuntu:17.10
ADD . /nginx_modsecurity_build
RUN /nginx_modsecurity_build/install.sh
ENTRYPOINT ["/sbin/inithostmount"]

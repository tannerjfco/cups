FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    iputils-ping \
    gpg \
    vim \
    locales \
    whois \
    cups \
    cups-client \
    cups-bsd \
    printer-driver-all \
    printer-driver-gutenprint \
    hpijs-ppds \
    hp-ppd  \
    hplip \
    printer-driver-foo2zjs

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en

RUN useradd \
    --groups=lp,lpadmin \
    --create-home \
    --home-dir=/home/print \
    --shell=/bin/bash \
    --password=$(mkpasswd print) \
    print

COPY cupsd.conf /etc/cups/cupsd.conf
RUN cp -a /etc/cups /etc/cups-defaults

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 631

ENTRYPOINT ["/entrypoint.sh"]

FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    avahi-daemon \
    avahi-utils \
    cups \
    cups-bsd \
    cups-client \
    curl \
    gpg \
    hp-ppd  \
    hpijs-ppds \
    hplip \
    iputils-ping \
    locales \
    printer-driver-all \
    printer-driver-foo2zjs \
    printer-driver-gutenprint \
    vim \
    whois && \
    locale-gen en_US.UTF-8

RUN sed -i 's/class LocalOpener(urllib_request.URLopener):/class LocalOpener:/' /usr/share/hplip/base/device.py && \
    sed -i 's/class LocalOpenerEWS_LEDM(urllib_request.URLopener):/class LocalOpenerEWS_LEDM:/' /usr/share/hplip/base/device.py && \
    sed -i 's/class LocalOpener_LEDM(urllib_request.URLopener):/class LocalOpener_LEDM:/' /usr/share/hplip/base/device.py && \
    sed -i 's/class LocalOpener_CDM(urllib_request.URLopener):/class LocalOpener_CDM:/' /usr/share/hplip/base/device.py

RUN HPLIP_VERSION=$(dpkg -s hplip | grep '^Version:' | awk '{print $2}' | sed 's/+.*//') && \
    case "$(dpkg --print-architecture)" in \
      amd64) HPLIP_ARCH=x86_64 ;; \
      arm64) HPLIP_ARCH=arm64 ;; \
      armhf) HPLIP_ARCH=arm32 ;; \
    esac && \
    curl -L -o /tmp/hplip-plugin.run \
      "https://www.openprinting.org/download/printdriver/auxfiles/HP/plugins/hplip-${HPLIP_VERSION}-plugin.run" && \
    sh /tmp/hplip-plugin.run --noexec --target /tmp/hplip-plugin && \
    mkdir -p /usr/share/hplip/prnt/plugins \
             /usr/share/hplip/scan/plugins \
             /usr/share/hplip/fax/plugins \
             /usr/share/hplip/data/firmware \
             /var/lib/hp && \
    # Print plugins
    for f in lj hbpl1; do \
      [ -f /tmp/hplip-plugin/${f}-${HPLIP_ARCH}.so ] && \
        cp /tmp/hplip-plugin/${f}-${HPLIP_ARCH}.so /usr/share/hplip/prnt/plugins/ && \
        ln -sf ${f}-${HPLIP_ARCH}.so /usr/share/hplip/prnt/plugins/${f}.so; \
    done && \
    # Scan plugins
    for f in bb_soap bb_soapht bb_marvell bb_escl bb_orblite; do \
      [ -f /tmp/hplip-plugin/${f}-${HPLIP_ARCH}.so ] && \
        cp /tmp/hplip-plugin/${f}-${HPLIP_ARCH}.so /usr/share/hplip/scan/plugins/ && \
        ln -sf ${f}-${HPLIP_ARCH}.so /usr/share/hplip/scan/plugins/${f}.so; \
    done && \
    # Fax plugin
    [ -f /tmp/hplip-plugin/fax_marvell-${HPLIP_ARCH}.so ] && \
      cp /tmp/hplip-plugin/fax_marvell-${HPLIP_ARCH}.so /usr/share/hplip/fax/plugins/ && \
      ln -sf fax_marvell-${HPLIP_ARCH}.so /usr/share/hplip/fax/plugins/fax_marvell.so; \
    chmod -f 755 /usr/share/hplip/prnt/plugins/*.so \
                  /usr/share/hplip/scan/plugins/*.so \
                  /usr/share/hplip/fax/plugins/*.so 2>/dev/null; \
    # All firmware files
    cp /tmp/hplip-plugin/*.fw.gz /usr/share/hplip/data/firmware/ && \
    # Mark plugin as installed
    printf '[plugin]\ninstalled=1\neula=1\nversion=%s\n' "${HPLIP_VERSION}" > /var/lib/hp/hplip.state && \
    rm -rf /tmp/hplip-plugin /tmp/hplip-plugin.run

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

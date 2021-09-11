# CUPS Docker Image

Multiarch docker image for CUPS

To run in docker command line:

```
docker run --name cups -d -p 631:631 --privileged -v /var/run/dbus:/var/run/dbus -v /dev/bus/usb:/dev/bus/usb ghcr.io/tannerjfco/cups
```

To run in docker-compose:

```
version: "3"
services:
  cups:
    container_name: cups
    image: ghcr.io/tannerjfco/cups
    ports:
      - "631:631"
    volumes:
      - "/var/run/dbus:/var/run/dbus"
      - "/dev/bus/usb:/dev/bus/usb"
    privileged: true
    restart: unless-stopped
```
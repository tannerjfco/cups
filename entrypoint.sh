#!/bin/sh
if [ ! -f /etc/cups/cupsd.conf ]; then
  cp -a /etc/cups-defaults/* /etc/cups/
fi

if [ ! -S /var/run/dbus/system_bus_socket ]; then
  mkdir -p /var/run/dbus
  if [ ! -f /var/lib/dbus/machine-id ]; then
    dbus-uuidgen > /var/lib/dbus/machine-id
  fi
  dbus-daemon --system
fi

avahi-daemon -D

exec /usr/sbin/cupsd -f

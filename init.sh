#!/bin/sh

#
# Script options (exit script on command fail).
#

set -e

#
# Define default Variables.
#
USER="isc"
GROUP="isc"
COMMAND_OPTIONS_DEFAULT="-f"
ISC_UID_DEFAULT="1000"
ISC_GID_DEFAULT="101"
COMMAND_BIND="/usr/sbin/named -u ${USER} -c /etc/bind/named.conf ${COMMAND_OPTIONS:=${COMMAND_OPTIONS_DEFAULT}}"
COMMAND_DHCP="/usr/sbin/dhcpd -4 -f -d --no-pid -cf /etc/dhcp/dhcpd.conf"

NAMED_UID_ACTUAL=$(id -u ${USER})
NAMED_GID_ACTUAL=$(id -g ${GROUP})

#
# Display settings on standard out.
#
echo "settings"
echo "=============="
echo
echo "  Username:        ${USER}"
echo "  Groupname:       ${GROUP}"
echo "  UID actual:      ${ISC_UID_ACTUAL}"
echo "  GID actual:      ${ISC_GID_ACTUAL}"
echo "  UID prefered:    ${ISC_UID:=${ISC_UID_DEFAULT}}"
echo "  GID prefered:    ${ISC_GID:=${ISC_GID_DEFAULT}}"
echo "  Command:         ${COMMAND_BIND}"
echo "  Command:         ${COMMAND_DHCP}"
echo

#
# Change UID / GID of named user.
#
echo "Updating UID / GID... "
if [[ ${ISC_GID_ACTUAL} -ne ${ISC_GID} -o ${ISC_UID_ACTUAL} -ne ${ISC_UID} ]]
then
    echo "change user / group"
    deluser ${USER}
    addgroup -g ${ISC_GID} ${GROUP}
    adduser -u ${ISC_UID} -G ${GROUP} -h /etc/bind -g 'Linux User named' -s /sbin/nologin -D ${USER}
    echo "[DONE]"
    echo "Set owner and permissions for old uid/gid files"
    find / -not \( -path /proc -prune \) -not \( -path /sys -prune \) -user ${ISC_UID_ACTUAL} -exec chown ${USER} {} \;
    find / -not \( -path /proc -prune \) -not \( -path /sys -prune \) -group ${ISC_GID_ACTUAL} -exec chgrp ${GROUP} {} \;
    echo "[DONE]"
else
    echo "[NOTHING DONE]"
fi

touch /var/lib/dhcpd/dhcpd.leases

#
# Set owner and permissions.
#
echo "Set owner and permissions... "
chown -R ${USER}:${GROUP} /var/bind /etc/bind /var/run/named /var/log/named /var/lib/dhcpd/dhcpd.leases
chmod -R o-rwx /var/bind /etc/bind /var/run/named /var/log/named /var/lib/dhcpd/dhcpd.leases
echo "[DONE]"

#
# Start named.
#
echo "Start named... "
exec ${COMMAND_BIND}
#
echo "Start dhcpd... "
exec ${COMMAND_DHCP}

#!/bin/bash
set -e

CONFIG_FILE=/etc/turnserver.conf

echo "REALM: $REALM"

echo "LISTENING_PORT: $LISTENING_PORT"
echo "TLS_LISTENING_PORT: $TLS_LISTENING_PORT"

echo "LISTENING_IPS: $LISTENING_IPS"
echo "RELAY_IPS: $RELAY_IPS"
echo "EXTERNAL_IPS: $EXTERNAL_IPS"

echo "MIN_PORT: $MIN_PORT"
echo "MAX_PORT: $MAX_PORT"

if [ -z "$LISTENING_IPS" ]; then
	LISTENING_IPS="$(ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"
fi

if [ -z "$RELAY_IPS" ]; then
	RELAY_IPS="$LISTENING_IPS"
fi

if [ -z "$EXTERNAL_IPS" ]; then
	EXTERNAL_IPS="$(dig +short myip.opendns.com @resolver1.opendns.com)"
fi

add_config_line() {
	if [ "$2" ]; then
		echo "$1=$2" >> "$CONFIG_FILE"
	else
		echo "$1" >> "$CONFIG_FILE"
	fi
}

rm -f "$CONFIG_FILE"

add_config_line listening-port $LISTENING_PORT
add_config_line tls-listening-port $TLS_LISTENING_PORT

for ip in $LISTENING_IPS; do
	add_config_line listening-ip $ip
done

for ip in $RELAY_IPS; do
	add_config_line relay-ip $ip
done

for ip in $EXTERNAL_IPS; do
	add_config_line external-ip $ip
done

if [ "$VERBOSE" == "1" ]; then
    add_config_line verbose
fi

add_config_line min-port $MIN_PORT
add_config_line max-port $MAX_PORT

add_config_line realm $REALM
add_config_line server-name $REALM
add_config_line mobility

if [ $ANONYMOUS -eq 0 ]; then
    add_config_line lt-cred-mech
    add_config_line user $USERNAME:$PASSWORD
else
    add_config_line no-auth
fi

add_config_line cert /etc/ssl/turn_server_cert.pem
add_config_line pkey /etc/ssl/turn_server_pkey.pem

add_config_line no-tlsv1
add_config_line no-tlsv1_1

add_config_line no-stdout-log
add_config_line log-file stdout

add_config_line fingerprint

echo
cat "$CONFIG_FILE"
echo

echo "Starting TURN server..."

turnserver

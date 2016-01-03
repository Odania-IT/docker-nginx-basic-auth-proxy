#!/usr/bin/env bash
set -e
if [[ ! -e /var/log/nginx/error.log ]]; then
	# The Nginx log forwarder might be sleeping and waiting
	# until the error log becomes available. We restart it in
	# 1 second so that it picks up the new log file quickly.
	(sleep 1 && sv restart /etc/service/nginx-log-forwarder)
fi

echo "Generating proxy configuration"

# Basic Auth?
if [ -n "${PROXY_AUTH_USER}" ]; then
	echo "Generating Proxy config for user: ${PROXY_AUTH_USER}"
	htpasswd -cm -db /etc/nginx/basic_auth.htpasswd $PROXY_AUTH_USER $PROXY_AUTH_PASSWORD
	cp /etc/nginx-vhosts/auth.vhost.conf /etc/nginx/sites-enabled/proxy.conf
else
	if [ -n "${PROXY_AUTH_USER_PASSWORD}" ]; then
		echo "Using pregenerated password hash: ${PROXY_AUTH_USER_PASSWORD}"
		echo $PROXY_AUTH_USER_PASSWORD > /etc/nginx/basic_auth.htpasswd
		cp /etc/nginx-vhosts/auth.vhost.conf /etc/nginx/sites-enabled/proxy.conf
	else
		if [ -n "${NO_AUTH_PROXY}" ]; then
			cp /etc/nginx-vhosts/no-auth.vhost.conf /etc/nginx/sites-enabled/proxy.conf
		fi
	fi
fi

# Add host
POSITION=$((`expr index $APP_PORT "://"` + 2))
TARGET_HOST=${APP_PORT:$POSITION}

echo "Setting TARGET_HOST to ${TARGET_HOST}"
sed -i s/TARGET_HOST/$TARGET_HOST/g /etc/nginx/sites-enabled/*.conf

exec /usr/sbin/nginx

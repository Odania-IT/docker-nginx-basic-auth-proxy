# docker-nginx-basic-auth-proxy

This image is based on the odaniait/docker-base image and installs nginx as a proxy. Basic Auth can be enabled to secure the app behind it.

You can either put in your own configuration via the volume
/etc/nginx/sites-enabled

or you can set environment variables to have a simple proxy. An example for docker compose looks like this:

```
nginx:
  build: /home/mike/workspace/docker/docker-nginx-basic-auth-proxy
  environment:
    PROXY_AUTH_USER: myuser
    PROXY_AUTH_PASSWORD: mypassword
  links:
    - registry:app
  restart: always
  tty: true
  stdin_open: true
registry:
  image: registry:2
  volumes:
    - /media/volumes/docker-registry:/var/lib/registry
  restart: always
  tty: true
  stdin_open: true
```

If you set the PROXY_AUTH_USER and PROXY_AUTH_PASSWORD the db file will be created for you. But you can also supply the
hashed result like:

PROXY_AUTH_USER_PASSWORD: myuser:mypasswordhash

In that case you do not have the clear password in the docker-compose file.

The target proxy will be detected from the link. The alias app is used internally and the string TARGET_HOST will be replaced
with the ip:port of the app in all files for the following pattern:
/etc/nginx/sites-enabled/*.conf

Attention:
If you use a volume the files will be changed. So if you use TARGET_HOST to have it automatically replaced make sure you have a copy
of the files.

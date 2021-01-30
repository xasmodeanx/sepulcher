# WebStore Services to support sepulcher

## Start KeyStore Instance (for Public Key Transfer)
```bash
KSIP="51.195.74.99"
RIP="172.17.0.1"
RPORT="6399"

docker run -d --rm --name keysredis \
-p ${RIP}:${RPORT}:6379 \
-v /srv/docker/keys/redis:/data \
redis

docker run -d --rm --name keyshttp \
-p ${KSIP}:80:8080 \
-e MAXPOSTSIZE=16384 \
-e REQPERIOD=4 -e REQCOUNT=1 \
-e REDISIP=${RIP} \
-e REDISPORT=${RPORT} \
-v /srv/docker/keys/httplog:/log \
fullaxx/webstore

docker run -d --rm --name keyshttps \
-p ${KSIP}:443:8080 \
-e MAXPOSTSIZE=16384 \
-e REQPERIOD=4 -e REQCOUNT=1 \
-e REDISIP=${RIP} \
-e REDISPORT=${RPORT} \
-e CERTFILE=config/live/keys.dspi.org/fullchain.pem \
-e KEYFILE=config/live/keys.dspi.org/privkey.pem \
-v /srv/docker/certbot:/cert \
-v /srv/docker/keys/httpslog:/log \
fullaxx/webstore
```

## Start MsgStore Instance (for Message Transfer)
```bash
MSIP="51.195.74.98"
RIP="172.17.0.1"
RPORT="6398"
docker pull redis
docker pull ubuntu:focal
docker pull fullaxx/webstore

docker run -d --rm --name msgsredis \
-p ${RIP}:${RPORT}:6379 \
-v /srv/docker/msgs/redis:/data \
redis

docker run -d --rm --name msgshttp \
-p ${MSIP}:80:8080 \
-e BAR=1 -e MAXPOSTSIZE=1000000 \
-e REQPERIOD=5 -e REQCOUNT=2 \
-e REDISIP=${RIP} \
-e REDISPORT=${RPORT} \
-v /srv/docker/msgs/httplog:/log \
fullaxx/webstore

docker run -d --rm --name msgshttps \
-p ${MSIP}:443:8080 \
-e BAR=1 -e MAXPOSTSIZE=1000000 \
-e REQPERIOD=5 -e REQCOUNT=2 \
-e REDISIP=${RIP} \
-e REDISPORT=${RPORT} \
-e CERTFILE=config/live/msgs.dspi.org/fullchain.pem \
-e KEYFILE=config/live/msgs.dspi.org/privkey.pem \
-v /srv/docker/certbot:/cert \
-v /srv/docker/msgs/httpslog:/log \
fullaxx/webstore
```

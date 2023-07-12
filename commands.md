## Run Docker Images
### Run Busybox image

```ps
docker run hello-world
docker run busybox
docker container ls (a)
docker run busybox echo "hello from busybox"
docker run --name shell -it busybox sh
	ls
	ifconfig
	exit
docker network ls
docker network inspect bridge
```

### Run basic container

```ps
docker run --name dockerdocs -d -p 80:80 docker/getting-started
docker run --name nginx -d -p 80:80 nginx:latest
docker stop dockerdocs
docker start nginx
docker run --name nginx -d -p 81:80 nginx:latest
curl localhost:81
```

### Configure bridge networking

##### Create container and new network

```ps
docker run --name busybox --network="none" -it busybox
	ifconfig
docker network create –d bridge mynetwork
docker network connect mynetwork busybox
docker inspect busybox -f "{{json .NetworkSettings.Networks }}"
docker network inspect none
docker network disconnect none busybox
docker network connect mynetwork busybox
```

##### Create second container on network

```ps
docker run --network="mynetwork" -it --name busybox2 busybox
	ifconfig
	ping <IP busybox>
docker network inspect mynetwork
docker network disconnect mynetwork busybox

ifconfig (busybox)

ping <IP busybox> (busybox2)
```

##### Remove first container from network and put it on a second one

```ps
docker network create -d bridge myothernetwork

docker network inspect mynetwork
docker network inspect myothernetwork

docker network connect myothernetwork busybox
ifconfig (busybox)

ping <new IP busybox> (busybox2)
```

### Modify and save running container

```ps
docker run --it --name template busybox
	mkdir workshop
	cd workshop
	touch test.txt
	cat test.txt
	printf 'Hellow\nWorld\n' > ./test.txt
	cat test.txt
	exit
docker container ls -a
docker commit template custombusybox
docker images
docker run --it --name mycustombusybox custombusybox
	cd workshop
	cat test.txt
```

## Deploy a basic container with static HTML

##### Move into correct directory and create first web server

```ps
cd c:\dockerk8sworkshop\1
docker build -t web-server:v1 .
docker images
docker run --name webserver1 -d -p 80:80 web-server:v1
docker container ls
```

##### Create second web server

```ps
cd ../2
docker build -t web-server:v2
docker run --name webserver2 -d -p 81:80 web-server:v2
docker container ls
```

##### Modify container

```ps
docker exec -u 0 -it webserver1 sh
apk update
apk add nano
cd usr/share/nginx/html
nano index.html
	ctrl+o
	ctrl+x
exit
```

##### Create custom image and run it

```ps
docker container ls
docker commit webserver1 web-server:v3
docker run --name webserver3 -d -p 82:80 web-server:v3
```

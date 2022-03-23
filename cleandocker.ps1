docker container stop $(docker container ls -aq)
docker container prune -f
docker rmi $(docker images -q) -f
docker container stop $(docker container ls -aq)
docker container prune -f
docker rmi $(docker images -q) -f
$networks = docker network ls --format "{{.Name}}"
foreach($network in $networks){
    if(($network -ne "bridge") -and ($network -ne "host") -and ($network -ne "none")){
        Write-Output "Removing" $network
        docker network rm $network
    }    
}
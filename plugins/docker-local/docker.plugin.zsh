alias drmc='docker ps -a | grep -i exit | awk '{print $1}' | xargs docker rm'
alias drmi='docker images | grep none | awk '{print $3}'| xargs docker rmi'
alias docker_run='docker run ${DOCKER_DNS_FLAGS} --rm --privileged -it'
alias docker_exec='docker exec -it'
alias docker_logs='docker logs'

alias bld_dns="export DOCKER_DNS_FLAGS='--dns=10.32.0.13 --dns=10.32.0.9 --dns-search=f4tech.com'"

dhost() {
    if [ -z "$1" ]; then
        echo $DOCKER_HOST
    else
        export DOCKER_HOST=tcp://${1}:${2-2375}
        unset DOCKER_TLS_VERIFY
        echo "DOCKER_HOST=$DOCKER_HOST"
    fi
}

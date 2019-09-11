alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -1"

docker_dev() {
    docker_user_home=/home/docker.dev
    docker_repo_base=daspoonman
    image=${docker_repo_base}/${1}
    extra_args=${2}

    eval "docker_run \
        -v ${HOME}/code:${docker_user_home}/code \
        -v ${HOME}/code/dotfiles/emacs/.spacemacs:${docker_user_home}/.spacemacs \
        -v ${HOME}/docker/emacs.cache:${docker_user_home}/.emacs.d/.cache \
        -v ${HOME}/docker/.zsh_history:${docker_user_home}/.zsh_history \
        -v ${HOME}/.ssh/id_rsa:${docker_user_home}/.ssh/id_rsa \
        -v ${HOME}/.ssh/config:${docker_user_home}/.ssh/config \
        -v ${HOME}/.ssh/tmp:${docker_user_home}/.ssh/tmp \
        -v ${HOME}/.docker:${docker_user_home}/.docker \
        -v ${HOME}/.mopctl:/config \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e GITHUB_USER=${GITHUB_USER} \
        -e GITHUB_EMAIL=${GITHUB_EMAIL} \
        -e SKIP_PULL=${SKIP_PULL} \
        --add-host dockerhost:203.0.113.0 \
        --network dev \
        -h dev \
        ${extra_args} \
        ${image}"
}

sm() docker_dev spacemacs

golang() {
    docker_user_home=/home/docker.dev
    declare extra_args

    if [[ -n "${EMACS_GUI}" ]]; then
        extra_args="-e DISPLAY=$(myip):0"
        open -a XQuartz
        socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
        sleep 2s
    fi

    extra_args="-v ${HOME}/.minikube:${docker_user_home}/.minikube \
       -v ${HOME}/.kube:${docker_user_home}/.kube"

    docker_dev golang ${extra_args}

    if [[ -n "${EMACS_GUI}" ]]; then
        pkill -i xquartz
        pkill socat
    fi
}

java_dev() {
    open -a XQuartz
    socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
    sleep 2s

    extra_args="-v ${HOME}/.gradle:${docker_user_home}/.gradle \
       -v ${HOME}/.java:${docker_user_home}/.java \
       -v ${HOME}/.idea:${docker_user_home}/.IdeaIC2016.3 \
       -p 5050:5050 \
       -e DISPLAY=$(myip):0"

    docker_dev java $extra_args

    pkill -i xquartz
    pkill socat
}

jf() {
    docker container run --rm \
           -v ${HOME}/docker/jfrog:/root/.jfrog \
           -v $(pwd):/tmp/af \
           -w /tmp/af \
           -e JFROG_CLI_LOG_LEVEL=DEBUG \
           docker.bintray.io/jfrog/jfrog-cli-go jfrog rt $@
}

vault() {
    docker container run --rm \
           -it \
           --cap-add=IPC_LOCK \
           -v ${HOME}/docker/vault/.token:/home/vault/.vault-token:rw \
           -e VAULT_ADDR=${VAULT_ADDRESS} \
           -e VAULT_NAMESPACE=${VAULT_NAMESPACE} \
           vault $@
}


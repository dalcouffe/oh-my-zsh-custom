alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -1"

docker_dev() {
    docker_user_home=/home/docker.dev
    docker_repo_base=daspoonman
    image=${docker_repo_base}/${1}
    extra_args=${2}

    eval "docker_run \
        --mount type=bind,consistency=delegated,source=${HOME}/code,destination=${docker_user_home}/code \
        --mount type=bind,consistency=delegated,source=${HOME}/docker/emacs.cache,destination=${docker_user_home}/.emacs.d/.cache \
        --mount type=bind,consistency=cached,source=${HOME}/docker/zsh_history,destination=${docker_user_home}/.zsh_history \
        --mount type=bind,consistency=cached,source=${HOME}/.ssh/id_rsa,destination=${docker_user_home}/.ssh/id_rsa \
        --mount type=bind,consistency=cached,source=${HOME}/.ssh/config,destination=${docker_user_home}/.ssh/config \
        --mount type=bind,consistency=cached,source=${HOME}/.ssh/tmp,destination=${docker_user_home}/.ssh/tmp \
        --mount type=bind,consistency=cached,source=${HOME}/.docker,destination=${docker_user_home}/.docker \
        --mount type=bind,consistency=cached,source=${HOME}/.mopctl,destination=/config \
        --mount type=bind,consistency=cached,source=/var/run/docker.sock,destination=/var/run/docker.sock \
        -e GITHUB_USER=${GITHUB_USER} \
        -e GITHUB_EMAIL=${GITHUB_EMAIL} \
        -e SKIP_PULL=${SKIP_PULL} \
        --network dev \
        -h dev \
        ${extra_args} \
        ${image}"
}
# --mount type=volume,source=code-sync,destination=${docker_user_home}/code
# --mount type=volume,source=emacs-cache-sync,destination=${docker_user_home}/.emacs.d/.cache
# --mount type=volume,source=zsh-history-sync,destination=${docker_user_home}/.zsh_history

# --mount type=bind,consistency=cached,source=${HOME}/code,destination=${docker_user_home}/code \
# --mount type=bind,consistency=cached,source=${HOME}/docker/emacs.cache,destination=${docker_user_home}/.emacs.d/.cache \
# --mount 'type=volume,source=nfsmount,destination=${docker_user_home}/code,volume-driver=local,volume-opt=type=nfs,volume-opt=device=:${HOME}/code,\"volume-opt=o=addr=host.docker.internal,nolock,rw,hard,nointr,nfsvers=3\"' \

sm() docker_dev spacemacs

golang() {
    mutagen compose --file=${HOME}/code/oh-my-zsh-custom/plugins/dev-env/golang.yml up -d
    mutagen compose --file=${HOME}/code/oh-my-zsh-custom/plugins/dev-env/golang.yml exec golang start_spacemacs_session
    mutagen compose --file=${HOME}/code/oh-my-zsh-custom/plugins/dev-env/golang.yml down
}

golang_old() {
    docker_user_home=/home/docker.dev
    declare extra_args

    if [[ -n "${EMACS_GUI}" ]]; then
        extra_args="-e DISPLAY=$(myip):0"
        open -a XQuartz
        socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
        sleep 2s
    fi

    # extra_args="-v ${HOME}/.minikube:${docker_user_home}/.minikube \
    #    -v ${HOME}/.kube:${docker_user_home}/.kube"

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


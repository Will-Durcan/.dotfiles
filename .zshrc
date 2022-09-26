# This file is sourced by all *interactive* bash shells on startup.  This
# file *should generate no output* or it will break the scp and rcp commands.

if [ $(uname -m) = 'arm64' ]; then
    COMPOSE_FILE='docker-compose-arm.yml'
else
    COMPOSE_FILE='docker-compose.yml'
fi

alias ll="ls -l"
alias lh="ls -lh"
alias la="ls -lah"
alias vir="vi -R"
alias top="top -o cpu"
alias screen='IGNOREEOF=1 screen'
alias grep='grep -H'
alias debugip="ifconfig en0 | egrep -o 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | tr -d '\n' | pbcopy && pbpaste && echo"

alias cdi='cd ~/projects/itrax/itracker/'
alias cdijs='cd ~/projects/itrax/itracker/media/website/js/'
alias cdr='cd ~/projects/rust'

alias Docker='open --background -a Docker'
alias dc='docker compose -f $COMPOSE_FILE'
alias itrax-debug='docker compose -f $COMPOSE_FILE run --rm -p 8000:8000 -p 5678:5678 itrax python -m ptvsd --host localhost --port 5678 manage.py runserver 0.0.0.0:8000'
alias itrax-logs='docker compose -f $COMPOSE_FILE logs -f itrax-noreload'
alias itrax-migrate='docker compose -f $COMPOSE_FILE run --rm itrax python manage.py migrate'
alias itrax-runserver='docker compose -f $COMPOSE_FILE up itrax'
alias itrax-server='docker compose -f $COMPOSE_FILE up -d nginx'
alias itrax-shell='docker compose -f $COMPOSE_FILE run -p 5678:5678 --rm itrax bash'
alias itrax-test='docker compose -f $COMPOSE_FILE run -p 5678:5678 --rm itrax python manage.py test --no-input --parallel --'

alias tf='terraform'
alias tfa='terraform apply'
alias tfi='terraform init'
alias tfp='terraform plan'

alias whatsmyip='dig +short ip @dns.toys'
function dy { dig +noall +answer +additional "$1" @dns.toys; }

export EDITOR=/usr/bin/vim
export CLICOLOR=1
export HISTCONTROL="ignoreboth"
export HISTIGNORE="[bf]g:exit:export AWS*:AWS*:ls:pwd:clear:mount:umount"
export BASH_SILENCE_DEPRECATION_WARNING=1
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# iTraX variables
export UI_SOURCE=~/projects/itrax/itracker/media/website/js
export SKIP_SLOW_TESTS=1
export USING_SAML=

# Core server variables
export LISTEN_ADDR='0.0.0.0'
export PORT=3000


export PATH=$PATH:~/bin
source "$HOME/.cargo/env"

################################################################################
# Vault stuff
################################################################################

alias sign-sshkey='vault write -field=signed_key ssh-client-signer/sign/administrator-role  public_key=@$HOME/.ssh/id_vault_authorised.pub valid_principals=administrator > ~/.ssh/vault-signed-key.pub'
alias get-deploy-creds='read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY < <(echo $(vault read aws/creds/deploy -format=json | jq -r ".data.access_key, .data.secret_key")) && export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY && sleep 10'
alias get-cresset-deploy-creds='read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY < <(echo $(vault read aws/creds/cresset-deploy -format=json | jq -r ".data.access_key, .data.secret_key")) && export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY && sleep 10'
alias get-artran-deploy-creds='read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY < <(echo $(vault read aws/creds/artran-deploy -format=json | jq -r ".data.access_key, .data.secret_key")) && export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY && sleep 10'
alias get-ecr-creds='read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY < <(echo $(vault read aws/creds/ecr-admin -format=json | jq -r ".data.access_key, .data.secret_key")) && export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY && sleep 10'
alias get-prod-ecr-creds='read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY < <(echo $(vault read aws-prod/creds/ecr -format=json | jq -r ".data.access_key, .data.secret_key")) && export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY && sleep 10'
# alias get-elixir-deploy-creds='read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY < <(echo $(vault read aws-elixir/creds/deploy -format=json | jq -r ".data.access_key, .data.secret_key")) && export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY'
alias clear-deploy-creds='unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY'

login-vault() {
    if [ "$#" -ne 1 ]; then
        echo -e "Usage:\n    login-vault <VAULT_NAME>" >&2
        return 64  # EX_USAGE
    fi

    VAULT_NAME=$1

    case $VAULT_NAME in
        artran)
            echo "Using the artran vault at https://vault.artran.co.uk:8200"
            export VAULT_ADDR='https://vault.artran.co.uk:8200'
            ;;

        elixir)
            echo "Using the elixir vault at https://vault.elixir-test.co.uk"
            export VAULT_ADDR='https://vault.elixir-test.co.uk'
            ;;
        *)
            echo "Unknown vault $VAULT_NAME" >&2
            return 64
            ;;
    esac

    vault login -token-only=true  -method=userpass username=ray > ~/."$1"-token
    switch-vault-tokens "$1"
}

use-vault() {
    if [ "$#" -ne 1 ]; then
        echo -e "Usage:\n    use-vault <VAULT_NAME>" >&2
        return 64  # EX_USAGE
    fi

    VAULT_NAME=$1

    case $VAULT_NAME in
        artran)
            echo "Using the artran vault at https://vault.artran.co.uk:8200"
            export VAULT_ADDR='https://vault.artran.co.uk:8200'
            ;;

        elixir)
            echo "Using the elixir vault at https://vault.elixir-test.co.uk"
            export VAULT_ADDR='https://vault.elixir-test.co.uk'
            ;;
        *)
            echo "Unknown vault $VAULT_NAME" >&2
            return 64
            ;;
    esac

    switch-vault-tokens "$1"
}

switch-vault-tokens() {
    if [ "$#" -ne 1 ]; then
        echo -e "Usage:\n    switch-vault-tokens <VAULT_NAME>" >&2
        return 64  # EX_USAGE
    fi

    rm -f ~/.vault-token
    ln -s ~/."$1"-token ~/.vault-token
}

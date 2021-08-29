#!/bin/bash

set -e

TERRAFORM_VERSION="1.0.5"

cd $(dirname "$BASH_SOURCE")

function terraform {
    [[ -x ".terraform/terraform" ]] && ".terraform/terraform" "$@"
}

function download_terraform {
    local version="$1"
    if [[ "$(terraform version | head -1)" != "Terraform v$version" ]]
    then
        mkdir -p ".terraform"
        echo "Downloading Terraform v$version ..." >&2
        local os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
        local url="https://releases.hashicorp.com/terraform/%s/terraform_%s_%s_amd64.zip"
        curl -sf "$(printf "$url" "$version" "$version" "$os_name")" -o ".terraform/terraform.zip"
        unzip -oq ".terraform/terraform.zip" -d ".terraform"
        rm ".terraform/terraform.zip"
    fi
}

download_terraform "$TERRAFORM_VERSION"

COMMAND="$1"

if [[ -z "${COMMAND}" ]]; then
    echo "Usage: $0 COMMAND ..." >&2
    exit 1
fi

shift 1

terraform init -reconfigure
terraform get -update=true

case "$COMMAND" in
apply|console|import|plan|refresh|validate)
    terraform "$COMMAND" "$@"
    ;;
init|output|providers|show|state|taint|untaint|workspace|force-unlock)
    terraform "$COMMAND" "$@"
    ;;
*)
    echo "Unsupported command: $COMMAND" >&2
    exit 1
    ;;
esac

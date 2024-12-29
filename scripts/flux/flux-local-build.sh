#!/usr/bin/env bash

set -o errexit

function validate() {
    local cluster_dir="$1"
    shift 1

    local flux_local_args=(
        "build"
        "all"
        "${cluster_dir}/main/flux"
        "$@"
    )

    echo "=== Validating ${cluster_dir}/main/flux ==="
    if ! flux-local build all "${flux_local_args[@]}"; then
        exit 1
    fi
}

function run() {
    local root_dir
    if ! root_dir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"; then
        echo "Failed to determine root dir"
        exit 1
    fi
    if [[ "${DEVBOX_SHELL_ENABLED:-0}" != "1" || "$DEVBOX_PROJECT_ROOT" != "$root_dir" ]]; then
        devbox run --config "${root_dir}" flux-local-build "$@"
        return $?
    fi

    local kubernetes_dir=$1
    local cluster_name=$2

    [[ -z "${kubernetes_dir}" ]] && echo "Kubernetes location not specified" && exit 1

    local clusters=()
    if [[ "$cluster_name" != "" ]]; then
        clusters+=( "${kubernetes_dir}/${cluster_name}" )
    else
        while IFS= read -r -d '' dir; do
            clusters+=( "${dir}" )
        done < <(find "${kubernetes_dir}" -mindepth 1 -maxdepth 1 -type d  -print0)
    fi
    for cluster in "${clusters[@]}"; do
        validate "$cluster"
    done
}

run "$@"

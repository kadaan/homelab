#!/usr/bin/env bash

set -o errexit
set -o pipefail

function validate() {
    local cluster_dir="$1"
    kustomize_args=("--load-restrictor=LoadRestrictionsNone")
    kustomize_config="kustomization.yaml"
    kubeconform_args=(
        "-strict"
        "-ignore-missing-schemas"
        "-skip"
        "Secret"
        "-schema-location"
        "default"
        "-schema-location"
        "https://kubernetes-schemas.pages.dev/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json"
        "-verbose"
    )

    echo "=== Validating standalone manifests in ${cluster_dir}/main/flux ==="
    find "${cluster_dir}/main/flux" -maxdepth 1 -type f -name '*.yaml' -print0 | while IFS= read -r -d $'\0' file;
    do
        kubeconform "${kubeconform_args[@]}" "${file}"
        if [[ ${PIPESTATUS[0]} != 0 ]]; then
            exit 1
        fi
    done

    echo "=== Validating kustomizations in ${cluster_dir}/main/flux ==="
    find "${cluster_dir}/main/flux" -type f -name $kustomize_config -print0 | while IFS= read -r -d $'\0' file;
    do
        echo "=== Validating kustomizations in ${file/%$kustomize_config} ==="
        kustomize build "${file/%$kustomize_config}" "${kustomize_args[@]}" | kubeconform "${kubeconform_args[@]}"
        if [[ ${PIPESTATUS[0]} != 0 ]]; then
            exit 1
        fi
    done

    echo "=== Validating kustomizations in ${cluster_dir}/main/service ==="
    find "${cluster_dir}/main/service" -type f -name $kustomize_config -print0 | while IFS= read -r -d $'\0' file;
    do
        echo "=== Validating kustomizations in ${file/%$kustomize_config} ==="
        kustomize build "${file/%$kustomize_config}" "${kustomize_args[@]}" | kubeconform "${kubeconform_args[@]}"
        if [[ ${PIPESTATUS[0]} != 0 ]]; then
            exit 1
        fi
    done
}

function run() {
    local root_dir
    if ! root_dir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"; then
        echo "Failed to determine root dir"
        exit 1
    fi
    if [[ "${DEVBOX_SHELL_ENABLED:-0}" != "1" || "$DEVBOX_PROJECT_ROOT" != "$root_dir" ]]; then
        devbox run --config "${root_dir}" kubeconform "$@"
        return $?
    fi

    local kubernetes_dir="${1:-}"
    local cluster_name="${2:-}"
    if [[ "$kubernetes_dir" == "" ]]; then
        kubernetes_dir="$(dirname "$(dirname "$root_dir")")/kubernetes"
    fi

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

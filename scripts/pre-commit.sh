#!/usr/bin/env bash

function run() {
    if [[ "${DEVBOX_SHELL_ENABLED:-0}" != "1" ]]; then
        devbox run pre-commit "$@"
        return $?
    fi

    if [[ "${IS_GIT_HOOK:-0}" == "1" ]]; then
        # start templated
        # shellcheck disable=SC2034
        INSTALL_PYTHON="$(which python)"
        ARGS=(hook-impl --config=.pre-commit-config.yaml --hook-type=pre-commit)
        # end templated

        HERE="$(cd "$(dirname "$0")" && pwd)"
        ARGS+=(--hook-dir "$HERE" -- "$@")

        pre-commit "${ARGS[@]}"
        return "$?"
    else
        pre-commit run "$@"
    fi
}

run "$@"

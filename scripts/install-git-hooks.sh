#!/usr/bin/env bash

function run() {
    if [[ "${DEVBOX_SHELL_ENABLED:-0}" != "1" ]]; then
        devbox run install-git-hooks "$@"
        return $?
    fi

    local hooks_dir="${DEVBOX_PROJECT_ROOT}/.git/hooks"
    local precommit_hook="$hooks_dir/pre-commit"
    cat << EOF > "$precommit_hook"
#!/usr/bin/env bash

function run() {
    local root="\$(dirname "\$(dirname "\$(cd "\$(dirname "\$0")" && pwd)")")"
    IS_GIT_HOOK=1 \${root}/scripts/pre-commit.sh "\$@"
}

run "\$@"
EOF
}

run "$@"

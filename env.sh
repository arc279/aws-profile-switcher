function awsenv-switch_profile() {
    local CONFIG=${AWS_CONFIG_FILE:-~/.aws/config}

    local tmpfile1=$(mktemp)
    cat <<'EOD' >${tmpfile1}
s/^[ \t]*\[(.*)\][ \t]*$/\1/p
EOD

    local tmpfile2=$(mktemp)
    cat <<'EOD' >${tmpfile2}
/^[ \t]*\[${PAT}\][ \t]*$/ {
    p;
    :LOOP;
    n;
    /^[ \t]*\[[^]]+\][ \t]*$/Q;
    p;
    b LOOP;
}
EOD

    local prof=$(
        sed -nE -f ${tmpfile1} ${CONFIG} \
            | fzf --preview "PAT={} envsubst<${tmpfile2} | sed -nE -f - ${CONFIG}" \
            | sed 's/profile //'
    )

    export AWS_PROFILE=${prof}
    echo export AWS_PROFILE=${prof}
}


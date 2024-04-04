export GIT_LHASH="$(echo "$GIT_REV" | sed "s/-.*//g")"
export GIT_SHASH="$(echo "$GIT_LHASH" | cut -c-7)"
export GIT_AUTHSDATE="$(date '+%Y-%m-%d' -d "@$GIT_TIMESTAMP" -u)"
export GIT_AUTHIDATE="$(date '+%Y-%m-%d %H:%m:%S %z' -d "@$GIT_TIMESTAMP" -u)"

export GIT_RELTAG="$GIT_SHASH"
export GIT_REF_DIRTY="$GIT_SHASH"
if echo "$GIT_REV" | grep -q "-dirty"; then
    export GIT_RELTAG="$GIT_RELTAG-*"
    export GIT_REF_DIRTY="$GIT_RELTAG-dirty"
fi

mkdir -pv .git
cat > .git/gitHeadInfo.gin <<EOI
\usepackage[%
    shash={$GIT_SHASH},
    lhash={$GIT_LHASH},
    authname={unknown},
    authemail={unknown@example.com},
    authsdate={$GIT_AUTHSDATE},
    authidate={$GIT_AUTHIDATE},
    authudate={$GIT_TIMESTAMP},
    commname={unknown},
    commemail={unknown@example.com},
    commsdate={$GIT_AUTHSDATE},
    commidate={$GIT_AUTHIDATE},
    commudate={$GIT_TIMESTAMP},
    refnames={(HEAD -> main)},
    firsttagdescribe={$GIT_RELTAG},
    reltag={$GIT_RELTAG}
]{gitexinfo}
EOI
cat .git/gitHeadInfo.gin
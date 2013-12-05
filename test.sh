#!/bin/bash

set -o nounset
set -e

SRC_DIR=`cd $(dirname $0) && pwd`
export PATH="$SRC_DIR/bin:$PATH"

qpushd() {
    pushd $1 > /dev/null
}

qpopd() {
    popd > /dev/null
}

interact() {
    bash -i
}


init() {
    rm -rf local server

    mkdir -p local

    qpushd local
    git init my_local_repo > /dev/null
    cd my_local_repo
    git config --local axis.root.url $tmpdir/server
    qpopd

    mkdir -p server/{me,foo,bar,baz}

    qpushd server/me
    git init --bare my_remote_repo.git > /dev/null
    qpopd

    qpushd server/foo
    git init --bare foo_remote_repo1.git > /dev/null
    git init --bare foo_remote_repo2.git > /dev/null
    qpopd
}

run_tests() {
    init
    qpushd local/my_local_repo
    local server_dir=$tmpdir/server

    echo "git axis should return axis url"
    [ "`git axis`" == "$server_dir" ]

    echo "git axis show should list axis users"
    [ "`git axis show | sort`" == "`echo -e 'bar\nbaz\nfoo\nme'`" ]

    echo "git axis show user should list axis user's repos"
    [ "`git axis show foo | sort`" == "`echo -e 'foo_remote_repo1.git\nfoo_remote_repo2.git'`" ]
}


if [[ $# -gt 0 && "$1" == "-i" ]]; then
    INTERACTIVE=1
else
    INTERACTIVE=0
fi

if [[ $# -gt 0 && "$1" == "-d" ]]; then
    DEBUG=1
else
    DEBUG=0
fi

tmpdir=`mktemp -d -t 'git-axis-test'`
sig_handler() {
    local rc="$?"
    if [[ $rc -ne 0 ]]; then
        echo "!!! stopped at line $1"
        [[ $DEBUG -eq 1 ]] && interact
    fi
    rm -rf $tmpdir
    exit
}
trap 'sig_handler $LINENO' int term exit

cd $tmpdir


if [[ $INTERACTIVE -eq 1 ]]; then
    init
    interact
    exit
else
    run_tests
fi

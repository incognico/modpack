#!/usr/bin/env bash
cd ~/.xonotic/smb/modpack
set -eu

git pull --tags

git submodule update --init --depth 100

declare qccDir='gmqcc'
declare qccRepo='https://gitlab.com/xonotic/gmqcc.git'
declare qccBranch='master'

if [ ! -d "$qccDir" ]; then
    git clone --depth=1 --branch=${qccBranch} ${qccRepo} ${qccDir}
else
    pushd ${qccDir} && git pull
    popd
fi

pushd ${qccDir} && make -j $(nproc)
popd

#!/usr/bin/env bash
cd ~/.xonotic/smb/modpack
set -eu

git pull --tags

git submodule update --init --depth 100

declare qccDir='gmqcc'
declare qccRepo='https://gitlab.com/xonotic/gmqcc.git'
declare qccBranch='master'

if [ -z "${CI-}" ]; then
    wget -P .cache -c https://github.com/MarioSMB/csprogs/raw/master/csprogs-$(git describe --tags upstream/master).pk3
fi

if [ ! -d "$qccDir" ]; then
    git clone --depth=1 --branch=${qccBranch} ${qccRepo} ${qccDir}
else
    pushd ${qccDir} && git pull
    popd
fi

pushd ${qccDir} && make -j $(nproc)
popd

#!/usr/bin/env bash

mod=~/.xonotic/smb/modpack
xon=~/.xonotic/data
www=/srv/www/distfiles.lifeisabug.com/htdocs/xonotic
csp=~/.xonotic/smb/modpack/xonotic/qsrc

pushd $mod

VERSION=$(git describe --tags --dirty=_)
PROG="csprogs"
ARCHIVE="${PROG}-${VERSION}.pk3"
PKGINFO="${PROG}-${VERSION}.txt"

cp $mod/*.dat $xon/.

echo -e "https://github.com/incognico/modpack\nhttps://github.com/MarioSMB/modpack" > "${PKGINFO}"
cp ${PROG}{,-${VERSION}}.dat
cp ${PROG}{,-${VERSION}}.lno
zip -9 "${ARCHIVE}" ${PROG}-${VERSION}.{dat,lno} "${PKGINFO}" && mv "${ARCHIVE}" $mod/.cache/.

rm ${PROG}-${VERSION}.{dat,lno} "${PKGINFO}"

rm $xon/${PROG}-*.pk3

cp $mod/.cache/${PROG}-$VERSION.pk3 $xon/.

for i in $xon/*.pk3
do
   ln -sf $i $www/`basename $i`
done

find $www -xtype l -delete

popd

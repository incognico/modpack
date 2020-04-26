#!/usr/bin/env sh

mod=~/.xonotic/smb/modpack
xon=~/.xonotic/data
www=/srv/www/distfiles.lifeisabug.com/htdocs/xonotic
tag=`git describe --tags upstream/master`

cp $mod/*.dat $xon/.
cp $mod/.cache/csprogs-$tag.pk3 $xon/.

for i in $xon/*.pk3
do
   ln -sf $i $www/`basename $i`
done

find $www -xtype l -delete

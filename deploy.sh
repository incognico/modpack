#!/usr/bin/env sh

tag=`git describe --tags upstream/master`

cp ~/.xonotic/smb/modpack/*.dat ~/.xonotic/data/.
cp ~/.xonotic/smb/modpack/.cache/csprogs-$tag.pk3 ~/.xonotic/data/.
cp ~/.xonotic/smb/modpack/.cache/csprogs-$tag.pk3 /srv/www/distfiles.lifeisabug.com/htdocs/xonotic/.

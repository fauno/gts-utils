#!/bin/bash

NAME=$1
DIRECTORY=/srv/jails/$NAME

if [ -e $DIRECTORY ]; then
	echo "Directory $DIRECTORY exists" > /dev/errout
	exit 1
fi

echo "Creando arbol"

mkdir -p $DIRECTORY/{etc,tmp,usr,var,dev}
mkdir -p $DIRECTORY/var/{www,cache,tmp,lib}
mkdir -p $DIRECTORY/usr/share

echo "Permisos"

chmod a+rw -R $DIRECTORY/tmp
chmod a+rw -R $DIRECTORY/var/{tmp,cache}

echo "Copiando timezones"

cp -r /usr/share/zoneinfo $DIRECTORY/usr/share

echo "Setting timezone as UTC"

cd $DIRECTORY/etc 

ln -s ../usr/share/zoneinfo/UTC localtime

echo "Creating nodes"

mknod $DIRECTORY/dev/null c 1 3
mknod $DIRECTORY/dev/random c 1 8
mknod -m 644 $DIRECTORY/dev/urandom c 1 9
chmod 666 $DIRECTORY/dev/{null,random,urandom}

echo "mounting directory /var/www/$NAME"

echo "# mount www directory on jail for $NAME" >> /etc/fstab
echo "/var/www/$NAME $DIRECTORY/var/www none bind" >> /etc/fstab

mount -a

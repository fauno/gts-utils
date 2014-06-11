#!/bin/bash

NAME=$1
DIRECTORY=/srv/http/$NAME

if [ -e $DIRECTORY ]; then
	echo "Directory $DIRECTORY exists" > /dev/errout
	exit 1
fi

echo "Creando arbol"
mkdir -p $DIRECTORY/{etc,tmp,usr/bin,dev,srv}

echo "Permisos"
chmod a+rw -R $DIRECTORY/tmp
chmod a+rw -R $DIRECTORY/var/{tmp,cache}

echo "Timezone"
cp --dereference /etc/localtime ${DIRECTORY}/etc/

echo "Creating nodes"
mknod $DIRECTORY/dev/null c 1 3
mknod $DIRECTORY/dev/random c 1 8
mknod -m 644 $DIRECTORY/dev/urandom c 1 9
chmod 666 $DIRECTORY/dev/{null,random,urandom}

echo "Done"

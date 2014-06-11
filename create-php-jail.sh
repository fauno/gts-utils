#!/bin/bash
# salir al primer error
set -e

NAME=$1
DIRECTORY=/srv/http/$NAME

# la jaula ya existe
test -f "${DIRECTORY}/.jail" && exit 1

echo "Arbol"
mkdir -p $DIRECTORY/{etc,tmp,usr/bin,dev,srv}

echo "Permisos"
chmod a+rw -R $DIRECTORY/tmp

echo "Timezone"
cp --dereference /etc/localtime ${DIRECTORY}/etc/

echo "Nodos"
mknod $DIRECTORY/dev/null c 1 3
mknod $DIRECTORY/dev/random c 1 8
mknod -m 644 $DIRECTORY/dev/urandom c 1 9
chmod 666 $DIRECTORY/dev/{null,random,urandom}

touch "${DIRECTORY}/.jail"

echo "Done"

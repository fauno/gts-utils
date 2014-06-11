#!/bin/bash
# salir al primer error
set -e

NAME=$1
DIRECTORY=/srv/http/$NAME

# la jaula ya existe
test -f "${DIRECTORY}/.jail" && exit 1

pushd "${DIRECTORY}" &>/dev/null

echo "Arbol"
mkdir -p {etc,tmp,usr/bin,dev,srv/http/${DIRECTORY}}

echo "Permisos"
chmod a+rw -R tmp

echo "Timezone"
cp --dereference /etc/localtime etc/
cp data/passwd etc/

echo "Nodos"
mknod dev/null c 1 3
mknod dev/random c 1 8
mknod -m 644 dev/urandom c 1 9
chmod 666 dev/{null,random,urandom}

touch .jail

echo "Done"

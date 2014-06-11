#!/bin/bash
# salir al primer error
set -e

NAME=$1
DIRECTORY=/srv/http/$NAME

# la jaula ya existe
test -d "${DIRECTORY}/jail" && exit 1

echo "Jail"
mkdir -p "${DIRECTORY}/jail"
pushd "${DIRECTORY}/jail" &>/dev/null

echo "Arbol"
mkdir -p {etc,tmp,usr/bin,dev,srv/http}
# linkear / a /srv/http/dominio para no tener que trabajar con
# /srv/http/dominio/srv/http/dominio en el host
ln -s / "srv/http/${DIRECTORY}"

echo "Permisos"
chmod a+rw -R tmp

echo "Timezone"
cp --dereference /etc/localtime etc/
cp data/passwd etc/
cp data/resolv.conf etc/

echo "Nodos"
mknod dev/null c 1 3
mknod dev/random c 1 8
mknod dev/urandom c 1 9
chmod 666 dev/{null,random,urandom}

echo "Done"
